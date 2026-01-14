#!/usr/bin/env python3

#  For WSL/Linux users, they need to install one of these packages:
#  sudo apt-get install xclip  # or
#  sudo apt-get install xsel

import os, argparse, readline, time
import datetime
from rich.console import Console
from rich.markdown import Markdown
from rich.spinner import Spinner

from openai import OpenAI
import httpx

from prompt_toolkit.layout import Layout, Window, HSplit, FloatContainer, Float, ConditionalContainer
from prompt_toolkit.layout.controls import BufferControl, FormattedTextControl
from prompt_toolkit.layout.dimension import D
from prompt_toolkit.filters import Condition
from prompt_toolkit.buffer import Buffer
from prompt_toolkit.key_binding.vi_state import InputMode
from prompt_toolkit.application.current import get_app

def format_tokens(tokens: int) -> str:
    if tokens >= 1_000_000:
        return f"{tokens / 1_000_000:.1f}M"
    elif tokens >= 1_000:
        return f"{tokens / 1_000:.1f}K"
    else:
        return str(tokens)

def read_file(filepath: str) -> str:
    """Reads the content of a file, expanding the user home directory."""
    try:
        # Expand user home directory in the path
        expanded_filepath = os.path.expanduser(filepath)
        with open(expanded_filepath, "r", encoding="utf-8") as f:
            return f.read().strip()
    except FileNotFoundError:
        return f"Error: Prompt file not found at {filepath}"
    except Exception as e:
        return f"Error reading prompt file {filepath}: {e}"


# Shortcut configuration - easily customizable by users
# Use valid prompt_toolkit key names: https://python-prompt-toolkit.readthedocs.io/en/stable/pages/advanced_topics/key_bindings.html#list-of-special-keys
SHORTCUT_MAPPINGS = {
    'a-`': '```\n',
    # Add more shortcuts here in the format: 'key-combination': 'text-to-insert'
    # Examples:
    # 'c-b': '**bold**',  # Ctrl+B for bold text
    # 'a-b': '---',       # Alt+B for horizontal rule
}

# System prompts menu configuration
PROMPT_MENU = {
    "Assistant": "You're a helpful assistant. Give me more exact answer. If no special instruction, please answer in Chinese.",
    "Software_explainer": "Work as an software expert to answer my question."
        "Tell me what the things I provided are. Use one example to illustrate the usage. Always respond in Chinese",
    "Doc_organizer": "整理文档，润色句子，改正错误，增加细节。直接给出整理后的中文Markdown文档，不要解释和总结。",
    "Translater": "{}".format(read_file("~/.vim/AI/translation.prt")),
}

class MenuState:
    """State for the prompt menu."""
    def __init__(self, prompts_dict):
        self.active = False
        self.prompts = list(prompts_dict.items())  # list of (key, text)
        self.selected_index = 0

    def activate(self):
        self.active = True
        self.selected_index = 0

    def deactivate(self):
        self.active = False

    def move_down(self):
        if self.selected_index < len(self.prompts) - 1:
            self.selected_index += 1

    def move_up(self):
        if self.selected_index > 0:
            self.selected_index -= 1

    def get_selected_text(self):
        if self.prompts:
            return self.prompts[self.selected_index][1]
        return ""

    def get_selected_key(self):
        if self.prompts:
            return self.prompts[self.selected_index][0]
        return ""

def create_shortcut_handler(text_to_insert):
    """Create a handler function for inserting text snippets"""
    def handler(event):
        event.app.current_buffer.insert_text(text_to_insert)
    return handler

# should export GEMINI_API_KEY in env
def main():
    MODELS = {
        "dpr": {
            "display": "deepseek-r1",
            "provider": "Deepseek",
            "model": "deepseek-reasoner",
            "endpoint": "https://api.deepseek.com",
            "api_key_env": "OPENAI_API_KEY",
        },
        "dpv": {
            "display": "deepseek-v2",
            "provider": "Deepseek",
            "model": "deepseek-chat",
            "endpoint": "https://api.deepseek.com",
            "api_key_env": "OPENAI_API_KEY",
        },
        "gmf": {
            "display": "gemini-3-flash",
            "provider": "Gemini",
            "model": "gemini-3-flash-preview",
            "endpoint": "https://generativelanguage.googleapis.com/v1alpha/openai/",
            "api_key_env": "GEMINI_API_KEY",
        },
        "gmfl": {
            "display": "gemini-2.5-flash-lite",
            "provider": "Gemini",
            "model": "gemini-2.5-flash-lite",
            "endpoint": "https://generativelanguage.googleapis.com/v1alpha/openai/",
            "api_key_env": "GEMINI_API_KEY",
        },
        "gmp": {
            "display": "gemini-2.5-pro (default)",
            "provider": "Gemini",
            "model": "gemini-2.5-pro",
            "endpoint": "https://generativelanguage.googleapis.com/v1alpha/openai/",
            "api_key_env": "GEMINI_API_KEY",
        },
    }
    DEFAULT_MODEL_ALIAS = "gmf"
    total_tokens_consumed = 0
    parser = argparse.ArgumentParser(description="Simple Gemini Chatbot in Terminal")
    parser.add_argument(
        "--prompt",
        help="System prompt for the chat session. Can be a string or a file path (e.g., './prompt.txt').",
        required=False,
    )
    parser.add_argument(
        "-c", "--cot", action="store_true", help="Enable Chain-of-Thought (CoT) mode"
    )
    parser.add_argument(
        "-s",
        "--switch",
        nargs="?",
        const=True,
        default=None,
        help="Switch to a specific LLM. Provide an alias, or leave empty for interactive selection.",
    )
    parser.add_argument(
        "-t",
        "--temperature",
        type=float,
        default=0.2,
        help="Set temperature for response generation (default: 0.2)",
    )
    parser.add_argument(
        "-i",
        "--individual",
        action="store_true",
        help="Enable individual mode (no conversation history)",
    )
    parser.add_argument(
        "--input",
        type=str,
        help="Direct question to ask the LLM (non-interactive mode)",
        required=False,
    )
    parser.add_argument(
        "--output",
        type=str,
        help="File path to save the conversation (work with --input)",
        required=False,
    )
    args = parser.parse_args()

    def save_chat_to_file(file, messages):
        # Format conversation history as markdown
        markdown_lines = []
        for msg in messages:
            if msg["role"] == "user":
                markdown_lines.append(f"\n---\n**Question:**\n\n{msg['content']}\n")
            elif msg["role"] == "assistant":
                markdown_lines.append(f"\n---\n**Answer:**\n\n{msg['content']}\n")

        markdown_lines.append(f"\n---\nModel: **{model_name}**")
        markdown_lines.append(f", Total tokens consumed: **{format_tokens(total_tokens_consumed)}**")

        # Write to file
        try:
            with open(file, 'w', encoding='utf-8') as f:
                f.writelines(markdown_lines)
                console.print(f"[green]Conversation saved to {file}[/green]")
        except Exception as e:
            console.print(f"[red]Error saving to file: {e}[/red]")

    def get_status(verbose=False):
        """Return a list of (label, value) for current chat status."""
        status = []

        # Display current Vim mode (Normal/Insert/Replace)
        try:
            app = get_app()
            # vi_state is only available when vi_mode=True in PromptSession
            if app and hasattr(app, 'vi_state'):
                mode_map = {
                    InputMode.INSERT: "Insert",
                    InputMode.NAVIGATION: "Normal",
                    InputMode.REPLACE: "Replace",
                }
                current_mode = mode_map.get(app.vi_state.input_mode, "Normal")
                status.append(("Mode", current_mode))
        except Exception:
            # Silently fail if not in an active prompt session or vi_state is missing
            pass

        # Total tokens consumed
        status.append(("Tokens", format_tokens(total_tokens_consumed)))
        # System prompt role
        prompt_role = system_prompt.get("role", "Unknown")
        status.append(("Role", prompt_role))

        if verbose:
            content = system_prompt.get("content", "")
            # Replace newlines with spaces for preview
            content_preview = content.replace('\n', ' ')
            if len(content_preview) > 60:
                content_preview = content_preview[:60] + "..."
            status.append(("Prompt content", content_preview))

        # LLM model name
        status.append(("Model", model_name))
        # Add more status items here in the future
        return status

    # Initialize conversation history
    conversation_history = []

    console = Console()

    # prompt
    system_prompt = {
        "role": "Assistant",
        "content": "You're a helpful assistant. Give me more exact answer. If no special instruction, please answer in Chinese."
    }
    if args.prompt:
        prompt_path_or_string = args.prompt
        if os.path.exists(prompt_path_or_string):
            try:
                with open(prompt_path_or_string, "r") as f:
                    content = f.read().strip()
                system_prompt["content"] = content
                system_prompt["role"] = "Custom"
                console.print(f"System instruction loaded from file: '{prompt_path_or_string}'") # Updated message to "System instruction"
            except Exception as e:
                console.print(f"Error reading prompt file '{prompt_path_or_string}': {e}")
                system_prompt["content"] = prompt_path_or_string # Fallback to treat as string if file reading fails
                system_prompt["role"] = "Custom"
        else:
            system_prompt["content"] = prompt_path_or_string
            system_prompt["role"] = "Custom"

    # prepare chat
    selected_model_alias = DEFAULT_MODEL_ALIAS
    if args.switch is True:  # -s without alias, interactive mode
        console.print("Please select a model:")
        for alias, config in MODELS.items():
            console.print(f"  [bold cyan]{alias}[/bold cyan]: {config['display']}")

        while True:
            try:
                alias_input = input("Enter model alias: ").strip()
                if alias_input in MODELS:
                    selected_model_alias = alias_input
                    break
                else:
                    console.print("[red]Invalid alias. Please try again.[/red]")
            except (KeyboardInterrupt, EOFError):
                console.print("\nSelection cancelled. Exiting.")
                return
    elif isinstance(args.switch, str):  # -s with alias
        if args.switch in MODELS:
            selected_model_alias = args.switch
        else:
            console.print(f"[red]Unknown model alias: '{args.switch}'.[/red]")
            console.print("Available aliases:")
            for alias, config in MODELS.items():
                console.print(f"  [bold cyan]{alias}[/bold cyan]: {config['display']}")
            return

    model_config = MODELS[selected_model_alias]
    llm_provider = model_config["provider"]
    model_name = model_config["model"]
    endpoint = model_config["endpoint"]
    api_key_env = model_config["api_key_env"]
    api_key = os.environ.get(api_key_env)

    if not api_key:
        console.print(f"[red]Error: {llm_provider}({model_name}) API key is required. Provide it via {api_key_env} environment variable.[/red]")
        return

    if llm_provider == "Deepseek":
        custom_client = httpx.Client(verify=False)
    else:  # Gemini
        custom_client = httpx.Client()

    client = OpenAI(api_key=api_key, base_url=endpoint, http_client=custom_client)

    console.print(f"Welcome to [bold green]{llm_provider}:{model_name}[/bold green] Chatbox in Terminal!")
    console.print(f"CoT: {'[bold green]enable[/bold green]' if args.cot else '[bold red]disable[/bold red]'}.")
    console.print(f"Individual mode: {'[bold green]enable[/bold green]' if args.individual else '[bold red]disable[/bold red]'}.")
    # console.print("Type 'exit', 'quit', or 'bye', or Ctrl+c to end the chat.")

    while True:
        from prompt_toolkit import PromptSession
        from prompt_toolkit.key_binding import KeyBindings
        from prompt_toolkit.keys import Keys
        from prompt_toolkit.styles import Style

        menu_state = MenuState(PROMPT_MENU)

        # Define shortcut handler function
        def create_shortcut_handler(text_to_insert):
            def handler(event):
                event.app.current_buffer.insert_text(text_to_insert)
            return handler

        # Create custom style to override bottom toolbar background to black
        custom_style = Style.from_dict({
            'bottom-toolbar': 'fg:black',           # Black background for toolbar container
            'bottom-toolbar.text': 'fg:ansiwhite',      # Black background for toolbar text
        })

        # 创建自定义键绑定
        kb = KeyBindings()

        @kb.add('c-t', eager=True)
        def _(event):
            """Toggle menu on Ctrl+T."""
            if menu_state.active:
                menu_state.deactivate()
            else:
                menu_state.activate()
            # Force redraw to update bottom toolbar
            event.app.invalidate()

        @kb.add('j', eager=True, filter=Condition(lambda: menu_state.active))
        def _(event):
            """Move down in menu."""
            menu_state.move_down()
            event.app.invalidate()

        @kb.add('k', eager=True, filter=Condition(lambda: menu_state.active))
        def _(event):
            """Move up in menu."""
            menu_state.move_up()
            event.app.invalidate()

        @kb.add('enter', eager=True, filter=Condition(lambda: menu_state.active))
        def _(event):
            """Select current menu item."""
            nonlocal system_prompt
            text = menu_state.get_selected_text()
            key = menu_state.get_selected_key()
            if text:
                system_prompt["content"] = text
                system_prompt["role"] = key.capitalize()
            menu_state.deactivate()
            event.app.invalidate()
            # Prevent default enter behavior (insert newline)
            return

        @kb.add('escape', eager=True, filter=Condition(lambda: menu_state.active))
        def _(event):
            """Cancel menu."""
            menu_state.deactivate()
            event.app.invalidate()

        @kb.add(Keys.ControlD, eager=True)
        def _exit(event):
            "按CTRL+D提交"
            if menu_state.active:
                menu_state.deactivate()
                event.app.invalidate()
            else:
                event.app.exit(result=event.app.current_buffer.text)

        # Add shortcut key bindings
        for key_combination, text_to_insert in SHORTCUT_MAPPINGS.items():
            # Handle special case for backtick with alt
            if key_combination == 'a-`':
                @kb.add('escape', '`', eager=True)
                def insert_code_block(event, text=text_to_insert):
                    event.app.current_buffer.insert_text(text)
            else:
                # Parse other key combinations
                if key_combination.startswith('c-'):
                    # Ctrl+key combination
                    key = key_combination[2:]
                    kb.add('c-' + key, eager=True)(create_shortcut_handler(text_to_insert))
                elif key_combination.startswith('a-'):
                    # Alt+key combination (Meta key)
                    key = key_combination[2:]
                    kb.add('escape', key, eager=True)(create_shortcut_handler(text_to_insert))
                else:
                    # Single key
                    kb.add(key_combination, eager=True)(create_shortcut_handler(text_to_insert))

        # Function to generate bottom toolbar fragments
        def get_bottom_toolbar():
            fragments = []
            if menu_state.active:
                # 显示提示菜单，采用类似 Claude 的深色主题设计
                # 背景为深黑色，文字使用浅色，选中项使用蓝色背景突出
                # fg: background bg:frontground
                fragments.append(("bg:ansigreen fg:ansiblack", "## Set System prompt. Use j/k to move, Enter to select, Esc to cancel "))
                fragments.append(("", "\n"))
                for idx, (key, text) in enumerate(menu_state.prompts):
                    # Truncate text to the first 40 characters for display
                    display_text = text[:40]
                    if idx == menu_state.selected_index:
                        base_style = "bg:ansiwhite fg:ansicyan"
                    else:
                        base_style = "bg:ansiwhite fg:ansiblack"
                    fragments.append((base_style, f"- {key}: "))
                    fragments.append((base_style, f"{display_text} \n"))
            else:
                # 显示聊天状态信息（单行）
                status_items = get_status()
                for i, (label, value) in enumerate(status_items):
                    fragments.append(("fg:ansiblack bg:ansicyan", f" {label}: "))
                    fragments.append(("fg:ansiblack bg:ansiwhite", f"{value}"))
                    if i < len(status_items) - 1:
                        fragments.append(("fg:ansiblack bg:ansiwhite", " , "))
            return fragments

        session = PromptSession(
            message=[("fg:ansiblue", "\nYou (Ctrl+c to Quit, Ctrl+d to Submit):\n")],
            multiline=True,
            key_bindings=kb,
            vi_mode=True,
            wrap_lines=True,
            prompt_continuation=lambda width, line_number, wrap_count: '> ' if line_number == 0 else '  ',
            style=custom_style,  # Use custom style with black toolbar background
            bottom_toolbar=get_bottom_toolbar,
        )

        user_input = None
        if args.input:
            user_input = args.input
        else:
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
                        # Check if there's an "all" argument
                        if len(command_parts) > 1 and command_parts[1].lower() == 'all':
                            # Format all conversation history
                            formatted_history = []
                            for msg in conversation_history:
                                role = "User" if msg["role"] == "user" else "Assistant"
                                formatted_history.append(f"{role}: {msg['content']}")
                            history_text = "\n\n".join(formatted_history)
                            pyperclip.copy(history_text)
                            console.print("[green]Copied entire conversation history to clipboard![/green]")
                        else:
                            # Find last assistant message (original behavior)
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

                # Reprocess the last question - ensure it's not None
                user_input = last_user_msg or ""
                console.print(f"[bold yellow]Retrying last question ...[/bold yellow]")
            elif command == '/save':
                # Generate timestamp for filename
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                filename = f"/tmp/chat_{timestamp}.md"
                save_chat_to_file(filename, conversation_history)
                continue
            elif command == '/st':
                # Display chat status
                status_items = get_status(verbose=True)
                console.print("[bold green]Chat Status:[/bold green]")
                for label, value in status_items:
                    console.print(f"  [bold cyan]{label}:[/bold cyan] {value}")
                continue
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
                # Build messages
                messages = [{"role": "system", "content": system_prompt["content"]}]
                if not args.individual and len(conversation_history) > 0:
                    messages.extend(conversation_history) # Include history only if not in individual mode
                messages.append({"role": "user", "content": user_input})

                conversation_history.append({"role": "user", "content": user_input})

                completion = client.chat.completions.create(
                    model=model_name,
                    messages=messages,
                    temperature=args.temperature,
                    stream=False
                )
                response = completion.choices[0].message.content or ""
                if completion.usage and completion.usage.total_tokens:
                    if args.individual:
                        total_tokens_consumed = completion.usage.total_tokens
                    else:
                        total_tokens_consumed += completion.usage.total_tokens

                # Save conversation context
                conversation_history.append({"role": "assistant", "content": response})

            end_time = time.time()
            elapsed_time = end_time - start_time
            markdown_output = Markdown(response)
            console.print(f"[bold green]{llm_provider}:[/bold green]", markdown_output)

            word_count = len(response.split())
            word_rate = word_count / elapsed_time if elapsed_time > 0 else 0

            console.print(
                f"\n[bold cyan]Model:[/bold cyan] [bold yellow]{model_name}[/bold yellow], ",
                f"[bold cyan]Time consumed:[/bold cyan] [bold yellow]{elapsed_time:.2f} seconds[/bold yellow], ",
                #  f"[bold cyan]Word rate:[/bold cyan] [bold yellow]{word_rate:.2f} words/second[/bold yellow], ",
                f"[bold cyan]Total tokens consumed:[/bold cyan] [bold yellow]{format_tokens(total_tokens_consumed)}[/bold yellow]"
            )

        except Exception as e:
            console.print(f"[red]Error communicating with {llm_provider}({model_name}) API: {e}[/red]")
            console.print("Please check your API key and internet connection.")

        console.rule(title="[bold magenta] End [/bold magenta]")

        # One shot LLM ask
        if args.input:
            if args.output:
                save_chat_to_file(args.output, conversation_history)
            return

if __name__ == "__main__":
    main()
