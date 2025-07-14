#!/usr/bin/env python3

#  For WSL/Linux users, they need to install one of these packages:
#  sudo apt-get install xclip  # or
#  sudo apt-get install xsel

import os, argparse, readline, time
import datetime
from rich.console import Console
from rich.markdown import Markdown
from rich.spinner import Spinner

from typing import Annotated, Literal, TypedDict
from pydantic import BaseModel

from langchain_core.messages import HumanMessage, SystemMessage, AIMessage, ToolMessage
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_community.agent_toolkits.load_tools import load_tools
from langchain_core.tools import tool
from langgraph.checkpoint.memory import MemorySaver
from langgraph.graph import END, START, StateGraph, MessagesState
from langgraph.graph.message import add_messages
from langgraph.prebuilt import ToolNode, tools_condition

from openai import OpenAI
import httpx

# from langchain.globals import set_debug
# set_debug(True)

def get_webchat_app():
    @tool
    class AskHuman(BaseModel):
        """
        You can ask human some questions to supply the context.
        It will help you understand what user want and what environment user uses.
        And help you analysis the problem.
        """
        request: str

    class State(TypedDict):
        messages: Annotated[list, add_messages]
        ask_human: bool


    tools = [AskHuman]
    loaded_tools = load_tools(["searx-search"],
                        searx_host="http://localhost:8888",
                        num_results=5)
    tools += loaded_tools
    # tools.append(get_location)
    print("tools:", tools)

    model = ChatGoogleGenerativeAI(
        model="gemini-2.5-flash",
        temperature=0.7
    ).bind_tools(tools)

    tool_node = ToolNode(tools)

    def agent_flow(state: State):
        response = model.invoke(state['messages'])
        ask_human = False
        if (
            response.tool_calls
            and response.tool_calls[0]["name"] == "AskHuman"
        ):
            ask_human = True
        return {"messages": [response], "ask_human": ask_human}

    def select_next_node(state: State):
        if state["ask_human"]:
            return "ask"
        return tools_condition(state)

    def create_response(response: str, ai_message: AIMessage):
        return ToolMessage(
            content=response,
            tool_call_id=ai_message.tool_calls[0]["id"],
        )

    def ask_human(state: State):
        new_messages = []
        print("\n[bold blue]You (Ctrl+d to Submit, Ctrl+c to Quit):[/bold blue] ", end="\n\n") # Updated prompt for multi-line input
        multi_line_input = []
        print("> ", end="")
        while True:
            try:
                line = input()
                multi_line_input.append(line)
            except (EOFError, KeyboardInterrupt):
                break
        user_input = "\n".join(multi_line_input) if multi_line_input else "No human response."

        if not isinstance(state["messages"][-1], ToolMessage):
            # Typically, the user will have updated the state during the interrupt.
            # If they choose not to, we will include a placeholder ToolMessage to
            # let the LLM continue.
            new_messages.append(create_response(user_input, state["messages"][-1]))
        return {"messages": new_messages,"ask_human": False}

    workflow = StateGraph(State)
    workflow.add_node("agent", agent_flow)
    workflow.add_node("tools", tool_node)
    workflow.add_node("ask", ask_human)

    workflow.add_edge(START, "agent")
    workflow.add_conditional_edges("agent", select_next_node)
    workflow.add_edge("tools", 'agent')
    workflow.add_edge("ask", 'agent')
    # workflow.add_edge("suggestion", "agent")

    app = workflow.compile(checkpointer=MemorySaver(), interrupt_before=["ask"])

    return app

def chat_with_tool(app, input):
    if app is None:
        raise Exception("app is None")

    system_prompt = """你是一个非常有用的assistant, 并且可以使用以下工具来帮助你完成任务：
    - 你可以调用SearxSearch 工具从网络上抓取相关信息，由你来决定search what。
      记住：search的结果只是用来作为参考，你不能认为它就是完全正确的从而就发送一个search结果的总结。
      你必须自己分析search结果，然后给出详细的回答和分析。
    """
    # - 你可以调用 AskHuman 工具来问3个问题，这个几个问题可以帮助你更好的了解问题的上下文。

   # `invoke` 方法的第一个参数是用来启动 LangGraph 工作流的 **初始输入数据**。
   # 对于 `StateGraph` 构建的工作流来说，这个初始输入数据就代表了工作流的 **初始状态**。
   # 它是一个字典 (dictionary)，并且和 state 息息相关。

    final_state = app.invoke(
        {"messages": [SystemMessage(content=f"{system_prompt}"), HumanMessage(content=f"{input}")]},
        config={"configurable": {"thread_id": 42}},
        debug=True,
    )

    current_turn_tokens = 0
    for msg in final_state["messages"]:
        msg.pretty_print()
        if isinstance(msg, AIMessage) and msg.response_metadata:
            token_usage = msg.response_metadata.get("token_usage")
            if token_usage:
                current_turn_tokens += token_usage.get("prompt_tokens", 0)
                current_turn_tokens += token_usage.get("completion_tokens", 0)
                current_turn_tokens += token_usage.get("input_tokens", 0) # For Gemini
                current_turn_tokens += token_usage.get("output_tokens", 0) # For Gemini

    return final_state["messages"][-1].content, current_turn_tokens

def format_tokens(tokens: int) -> str:
    if tokens >= 1_000_000:
        return f"{tokens / 1_000_000:.1f}M"
    elif tokens >= 1_000:
        return f"{tokens / 1_000:.1f}K"
    else:
        return str(tokens)

# should export GEMINI_API_KEY in env
def main():
    total_tokens_consumed = 0
    parser = argparse.ArgumentParser(description="Simple Gemini Chatbot in Terminal")
    parser.add_argument("--prompt", help="System prompt for the chat session. Can be a string or a file path (e.g., './prompt.txt').", required=False)
    parser.add_argument("-c", "--cot", action="store_true", help="Enable Chain-of-Thought (CoT) mode")
    parser.add_argument("-w", "--websearch", action="store_true", help="Enable tool use mode")
    parser.add_argument("-s", "--switch", action="store_true", help="Switch to specific LLM")
    parser.add_argument("-t", "--temperature", type=float, default=0.2, help="Set temperature for response generation (default: 0.2)")
    parser.add_argument("-i", "--individual", action="store_true", help="Enable individual mode (no conversation history)")
    args = parser.parse_args()

    # Initialize conversation history
    conversation_history = []

    console = Console()

    # prompt
    system_prompt = "You're a helpful assistant. Give me more exact answer. You can think for few some time."
    if args.prompt:
        prompt_path_or_string = args.prompt
        if os.path.exists(prompt_path_or_string):
            try:
                with open(prompt_path_or_string, "r") as f:
                    system_prompt = f.read().strip()
                console.print(f"System instruction loaded from file: '{prompt_path_or_string}'") # Updated message to "System instruction"
            except Exception as e:
                console.print(f"Error reading prompt file '{prompt_path_or_string}': {e}")
                system_prompt = prompt_path_or_string # Fallback to treat as string if file reading fails
        else:
            system_prompt = prompt_path_or_string

    webchatapp = get_webchat_app() if args.websearch else None

    # prepare chat
    model_name = ""
    llm_provider = "Deepseek" if args.switch else "Gemini"
    if llm_provider == "Deepseek":
        api_key = os.environ.get("OPENAI_API_KEY")
        if not api_key:
            print("Error: Deepseek API key is required. Provide it via OPENAI_API_KEY environment variable.")
            return
        endpoint = "https://api.deepseek.com"
        model_name = "deepseek-reasoner"
        custom_client = httpx.Client(verify=False)
    else:
        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            print("Error: Gemini API key is required. Provide it via GEMINI_API_KEY environment variable.")
            return
        endpoint = "https://generativelanguage.googleapis.com/v1alpha/openai/"
        #  model_name = "gemini-2.0-flash-thinking-exp"
        model_name = "gemini-2.5-pro"
        custom_client = httpx.Client()

    client = OpenAI(api_key=api_key, base_url=endpoint, http_client=custom_client)

    console.print(f"Welcome to [bold green]{llm_provider}:{model_name}[/bold green] Chatbox in Terminal!")
    console.print(f"CoT: {'[bold green]enable[/bold green]' if args.cot else '[bold red]disable[/bold red]'}.")
    console.print(f"Web search: {'[bold green]enable[/bold green]' if args.websearch else '[bold red]disable[/bold red]'}.")
    console.print(f"Individual mode: {'[bold green]enable[/bold green]' if args.individual else '[bold red]disable[/bold red]'}.")
    # console.print("Type 'exit', 'quit', or 'bye', or Ctrl+c to end the chat.")

    while True:
        from prompt_toolkit import PromptSession
        from prompt_toolkit.key_binding import KeyBindings
        from prompt_toolkit.keys import Keys

        # 创建自定义键绑定
        kb = KeyBindings()

        @kb.add(Keys.ControlD, eager=True)
        def _exit(event):
            "按CTRL+D提交"
            event.app.exit(result=event.app.current_buffer.text)

        session = PromptSession(
            message=[("fg:ansiblue", "\nYou (Ctrl+c to Quit, Ctrl+d to Submit):\n")],
            multiline=True,
            key_bindings=kb,
            vi_mode=True,  # 启用vi风格导航
            wrap_lines=True,
            prompt_continuation=lambda width, line_number, wrap_count: '> ' if line_number == 0 else '  ',
            style=None,
            #  bottom_toolbar=[
            #      ("bg:ansiblue fg:white", " Quit "),
            #      ("", " Ctrl+c "),
            #      ("bg:ansigreen fg:white", " Submit "),
            #      ("", " ESC → Enter ")
            #  ]
        )

        try:
            user_input = session.prompt()
        except KeyboardInterrupt:
            console.print("\nGoodbye!")
            quit()

        if not user_input:
            print("None input !!\n\n")
            continue

        # Handle commands starting with '/'
        if user_input.strip().startswith('/'):
            command_parts = user_input.strip().split(maxsplit=1)
            command = command_parts[0]
            # args = command_parts[1] if len(command_parts) > 1 else "" # Not used for /new yet

            if command == '/new':
                conversation_history = []
                total_tokens_consumed = 0
                console.print("[bold green]Started a new conversation session.[/bold green]")
                continue
            elif command == '/raw':
                if conversation_history:
                    # Find last assistant message
                    for msg in reversed(conversation_history):
                        if msg["role"] == "assistant":
                            console.print("\n[bold yellow]RAW MESSAGE:[/bold yellow]")
                            console.print(msg["content"])
                            break
                    else:
                        console.print("[red]No assistant message in history[/red]")
                else:
                    console.print("[red]No conversation history[/red]")
                continue
            elif command == '/copy':
                try:
                    import pyperclip
                    if conversation_history:
                        # Find last assistant message
                        for msg in reversed(conversation_history):
                            if msg["role"] == "assistant":
                                pyperclip.copy(msg["content"])
                                console.print("[green]Copied last message to clipboard![/green]")
                                break
                        else:
                            console.print("[red]No assistant message to copy[/red]")
                    else:
                        console.print("[red]No conversation history[/red]")
                except Exception as e:
                    if "Pyperclip could not find a copy/paste mechanism" in str(e):
                        console.print("[red]Clipboard access requires one of these packages:")
                        console.print("[yellow]For Linux/WSL: Install 'xclip' or 'xsel' package")
                        console.print("  sudo apt-get install xclip or sudo apt-get install xsel[/yellow]")
                        console.print("[yellow]For Windows: No additional requirements[/yellow]")
                        console.print("[yellow]For MacOS: Install pbcopy/pbpaste[/yellow][/red]")
                    elif isinstance(e, ImportError):
                        console.print("[red]pyperclip not installed. Install with: pip install pyperclip[/red]")
                    else:
                        console.print(f"[red]Clipboard error: {e}[/red]")
                continue
            elif command == '/retry':
                if args.individual:
                    console.print("[red]Cannot retry in individual mode[/red]")
                    continue

                if not conversation_history:
                    console.print("[red]No history to retry[/red]")
                    continue

                # Find last user message
                last_user_msg = None
                for msg in reversed(conversation_history):
                    if msg["role"] == "user":
                        last_user_msg = msg["content"]
                        break

                if not last_user_msg:
                    console.print("[red]No previous question found[/red]")
                    continue

                # Reprocess the last question
                user_input = last_user_msg
                console.print(f"[bold yellow]Retrying last question ...[/bold yellow]")
            else:
                console.print(f"[bold red]Unknown command:[/bold red] {command}")
                continue

        if user_input.lower() in ["exit", "quit", "bye"]:
            console.print("Goodbye!")
            break

        console.print("\n")
        console.rule(title="[bold magenta]Question[/bold magenta]")
        console.print(user_input)
        console.rule(title="[bold magenta]Answer[/bold magenta]")

        try:
            start_time = time.time()
            spinner = Spinner("dots", text="[bold cyan]Waiting response ...[/bold cyan]")
            with console.status(spinner): # Use status to manage the spinner
                if args.websearch:
                    response_content, current_turn_tokens = chat_with_tool(webchatapp, user_input)
                    response = response_content
                    total_tokens_consumed += current_turn_tokens
                else:
                    # Build messages
                    messages = [{"role": "system", "content": system_prompt}]
                    if not args.individual:
                        messages.extend(conversation_history) # Include history only if not in individual mode
                    messages.append({"role": "user", "content": user_input})

                    if not args.individual:
                        conversation_history.append({"role": "user", "content": user_input})

                    completion = client.chat.completions.create(
                        model=model_name,
                        messages=messages,
                        temperature=args.temperature,
                        stream=False
                    )
                    response = completion.choices[0].message.content
                    if completion.usage and completion.usage.total_tokens:
                        total_tokens_consumed += completion.usage.total_tokens

                    # Save conversation context only if not in individual mode
                    if not args.individual:
                        conversation_history.append({"role": "assistant", "content": response})

            end_time = time.time()
            elapsed_time = end_time - start_time
            markdown_output = Markdown(response)
            console.print(f"[bold green]{llm_provider}:[/bold green]", markdown_output)

            word_count = len(response.split())
            word_rate = word_count / elapsed_time if elapsed_time > 0 else 0

            console.print(
                f"\n[bold cyan]Time consumed:[/bold cyan] {elapsed_time:.2f} seconds",
                f"[bold cyan]Word rate:[/bold cyan] {word_rate:.2f} words/second",
                f"\n[bold cyan]Total tokens consumed:[/bold cyan] {format_tokens(total_tokens_consumed)}"
            )

        except Exception as e:
            console.print(f"Error communicating with Gemini API: {e}")
            console.print("Please check your API key and internet connection.")

        console.rule(title="[bold magenta] End [/bold magenta]")

if __name__ == "__main__":
    main()
