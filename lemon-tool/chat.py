#!/usr/bin/env python3

#  For WSL/Linux users, they need to install one of these packages:
#  sudo apt-get install xclip  # or
#  sudo apt-get install xsel

import argparse
import datetime
import json
import os
import time
from typing import Any, Dict, List, Optional

import httpx
from openai import OpenAI
from prompt_toolkit import PromptSession
from prompt_toolkit.application.current import get_app
from prompt_toolkit.filters import Condition
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.key_binding.vi_state import InputMode
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.spinner import Spinner

# --- Utilities ---


def format_tokens(tokens: int) -> str:
    """Format token count for display."""
    if tokens >= 1_000_000:
        return f"{tokens / 1_000_000:.1f}M"
    elif tokens >= 1_000:
        return f"{tokens / 1_000:.1f}K"
    else:
        return str(tokens)


def read_file(filepath: str) -> str:
    """Reads the content of a file, expanding the user home directory."""
    try:
        expanded_filepath = os.path.expanduser(filepath)
        with open(expanded_filepath, "r", encoding="utf-8") as f:
            return f.read().strip()
    except FileNotFoundError:
        return f"Error: Prompt file not found at {filepath}"
    except Exception as e:
        return f"Error reading prompt file {filepath}: {e}"


class AIPrompt:
    """Represents a structured AI prompt with role, description, rules, and behaviors.
    Rulse and behaviors could be str/list/tuple, path or literal.
    """

    def __init__(
        self,
        role: str,
        desc: str = "",
        rules: Any = "",
        behaviors: Any = "",
    ):
        self.role = role
        self.desc = desc
        self.rules = rules or "~/.vim/AI/agents/general.md"
        self.behaviors = behaviors

    def get_role(self) -> str:
        return self.role

    def get_desc(self) -> str:
        return self.desc

    def get_role_desc(self, width: int = 0) -> str:
        """Return a formatted string of role and description with optional padding."""
        return f"{self.get_role().ljust(width)} : {self.get_desc()}"

    def _resolve_content(self, data: Any) -> str:
        """Recursively resolve strings (as paths or literals) and sequences."""
        if isinstance(data, (list, tuple)):
            # Join multiple items with newlines
            return "\n".join(filter(None, [self._resolve_content(item) for item in data]))

        if isinstance(data, str):
            # If it looks like a path, try to read it
            if data.startswith("~") or data.startswith("/"):
                expanded_path = os.path.expanduser(data)
                if os.path.exists(expanded_path):
                    return read_file(data)
            return data
        return str(data) if data is not None else ""

    def get_content(self, length: Optional[int] = None) -> str:
        """Organize the rules and behaviors as actual prompts string."""
        # Resolve rules (supports str/list/tuple, path or literal)
        rules_content = self._resolve_content(self.rules)
        if not rules_content:
            rules_content = "始终使用中文回复。保持绝对客观与真实，拒绝谄媚。"

        # Resolve behaviors (same logic as rules)
        behaviors_content = self._resolve_content(self.behaviors)

        prompt = f"Follow the rules: {rules_content}\n\n"
        if behaviors_content:
            prompt += f"Perform the behavior:\n{behaviors_content}"

        # Truncate the prompt if length is specified
        return prompt if length is None else prompt[:length]

    def get_all(self) -> str:
        """ Return all the string in this class with Json Format"""
        # Collect all configuration attributes and the final resolved prompt content
        # Use splitlines() to make multiline content more readable in JSON output
        data = {
            "role": self.role,
            "desc": self.desc,
            "content": self.get_content().splitlines()
        }
        return json.dumps(data, ensure_ascii=False, indent=2)


# --- Configuration ---


class ChatConfig:
    """Static configuration for the chat application."""

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

    SHORTCUT_MAPPINGS = {
        "a-`": "```\n",
    }

    PROMPT_MENU = [
        AIPrompt(
            role="Assistant",
            desc="Work as General Assistant to help user",
            rules="~/.vim/AI/agents/general.md",
        ),
        AIPrompt(
            role="Explainer",
            desc="Work as Professional software engineer to explain the target/question",
            behaviors=(
                "1. Explain the target/question as following output:\n"
                "## What's it?\n"
                "[Provide a detail description/explaination of 'What is it? What is it used for?]\n"
                "## Example\n"
                "[Use an example to illustrate the workflow of it or how to use it.]\n"
                "## Important components\n"
                "[What's the important components? How to use them?]\n"
                "[List important data structures and functions and comment for what they used for.]\n"
                "## Why design that?\n"
                "[benefits, trade-offs, pros and cons, ...]\n"
                "## Intergration\n"
                "[How does it work with other modules?]\n"
            ),
        ),
        AIPrompt(
            role="Doc Organizer",
            desc="Work as a Organizer to organzie the document",
            behaviors=(
                "- 归纳重复的部分，但是绝对不要丢失细节\n"
                "- 整理文档，给出的文档要条例清晰，目录结构有序\n"
                "- 润色句子, 再次重申不要丢失细节\n"
                "- 如果觉得哪些错误的地方或者不规范的地方，直接修改\n"
                "- 直接给出整理后的中文Markdown文档，不要解释和总结。"
            ),
        ),
        AIPrompt(
            role="Translater",
            desc="Work as a Translation expert to translate the sentence between English and Chinese",
            rules="~/.vim/AI/translation.prt",
        ),
    ]
    DEFAULT_PROMPT = PROMPT_MENU[0]



# --- State Management ---


class MenuState:
    """State for the prompt menu."""

    def __init__(self, prompts: List[AIPrompt]):
        self.active = False
        self.prompts = prompts
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

    def get_selected_prompt(self) -> AIPrompt:
        return self.prompts[self.selected_index]


class ChatState:
    """Dynamic state of the chat session."""

    def __init__(self):
        self.conversation_history: List[Dict[str, str]] = []
        self.total_tokens_consumed = 0
        self.current_prompt = ChatConfig.DEFAULT_PROMPT
        self.model_name = ""
        self.llm_provider = ""

    def reset(self):
        self.conversation_history = []
        self.total_tokens_consumed = 0


# --- API Client ---


class ModelClient:
    """Handles communication with LLM APIs."""

    def __init__(self, model_alias: str):
        self.config = ChatConfig.MODELS[model_alias]
        self.provider = self.config["provider"]
        self.model_name = self.config["model"]
        self.endpoint = self.config["endpoint"]

        api_key = os.environ.get(self.config["api_key_env"])
        if not api_key:
            raise ValueError(
                f"API key for {self.provider} not found in {self.config['api_key_env']}"
            )

        # Deepseek requires disabling SSL verification in some environments
        custom_client = httpx.Client(verify=(self.provider != "Deepseek"))
        self.client = OpenAI(
            api_key=api_key, base_url=self.endpoint, http_client=custom_client
        )

    def get_completion(self, messages: List[Dict[str, str]], temperature: float) -> Any:
        return self.client.chat.completions.create(
            model=self.model_name,
            messages=messages,
            temperature=temperature,
            stream=False,
        )


# --- UI & Interaction ---


class ChatInterface:
    """Handles the terminal UI using prompt_toolkit."""

    def __init__(self, state: ChatState, menu_state: MenuState):
        self.state = state
        self.menu_state = menu_state
        self.kb = self._create_key_bindings()
        self.style = Style.from_dict(
            {
                "bottom-toolbar": "fg:black",
                "bottom-toolbar.text": "fg:ansiwhite",
            }
        )

    def _create_key_bindings(self) -> KeyBindings:
        kb = KeyBindings()

        @kb.add("c-t", eager=True)
        def _toggle_menu(event):
            if self.menu_state.active:
                self.menu_state.deactivate()
            else:
                self.menu_state.activate()
            event.app.invalidate()

        @kb.add("j", eager=True, filter=Condition(lambda: self.menu_state.active))
        def _menu_down(event):
            self.menu_state.move_down()
            event.app.invalidate()

        @kb.add("k", eager=True, filter=Condition(lambda: self.menu_state.active))
        def _menu_up(event):
            self.menu_state.move_up()
            event.app.invalidate()

        @kb.add("enter", eager=True, filter=Condition(lambda: self.menu_state.active))
        def _menu_select(event):
            prompt = self.menu_state.get_selected_prompt()
            self.state.current_prompt = prompt
            self.menu_state.deactivate()
            event.app.invalidate()

        @kb.add(
            "enter",
            eager=True,
            filter=Condition(
                lambda: not self.menu_state.active
                and get_app().vi_state.input_mode == InputMode.NAVIGATION
            ),
        )
        def _normal_enter_submit(event):
            # In Normal mode, Enter triggers submission
            event.app.exit(result=event.app.current_buffer.text)

        @kb.add("escape", eager=True, filter=Condition(lambda: self.menu_state.active))
        def _menu_cancel(event):
            self.menu_state.deactivate()
            event.app.invalidate()

        @kb.add("escape", filter=Condition(lambda: not self.menu_state.active))
        def _vi_mode(event):
            if hasattr(event.app, "vi_state"):
                if event.app.vi_state.input_mode in (
                    InputMode.INSERT,
                    InputMode.REPLACE,
                ):
                    event.app.vi_state.input_mode = InputMode.NAVIGATION
                    buffer = event.app.current_buffer
                    if (
                        buffer.cursor_position > 0
                        and buffer.text[
                            buffer.cursor_position - 1 : buffer.cursor_position
                        ]
                        != "\n"
                    ):
                        buffer.cursor_position -= 1
            event.app.invalidate()

        @kb.add(Keys.ControlD, eager=True)
        def _submit(event):
            if self.menu_state.active:
                self.menu_state.deactivate()
                event.app.invalidate()
            else:
                event.app.exit(result=event.app.current_buffer.text)

        # Add shortcuts
        for key_comb, text in ChatConfig.SHORTCUT_MAPPINGS.items():
            if key_comb == "a-`":

                @kb.add("escape", "`", eager=True)
                def _insert_code(event, t=text):
                    event.app.current_buffer.insert_text(t)

            elif key_comb.startswith("c-"):
                kb.add("c-" + key_comb[2:], eager=True)(
                    self._create_insert_handler(text)
                )
            elif key_comb.startswith("a-"):
                kb.add("escape", key_comb[2:], eager=True)(
                    self._create_insert_handler(text)
                )

        return kb

    def _create_insert_handler(self, text):
        def handler(event):
            event.app.current_buffer.insert_text(text)

        return handler

    def get_prompt_message(self):
        """Generate dynamic prompt message based on Vi mode."""
        mode = InputMode.INSERT
        try:
            app = get_app()
            if app and hasattr(app, "vi_state"):
                mode = app.vi_state.input_mode
        except Exception:
            pass

        # Determine which key to show based on mode
        submit_key = "Enter" if mode == InputMode.NAVIGATION else "Ctrl+d"

        return [
            ("fg:ansiblue", "\nYou ("),
            ("fg:ansired bold", "Ctrl+c"),
            ("fg:ansiblue", " to Quit, "),
            ("fg:ansired bold", submit_key),
            ("fg:ansiblue", " to Submit):\n"),
        ]

    def get_status_fragments(self, verbose=False):
        """Generate status bar content."""
        if self.menu_state.active:
            fragments = [
                (
                    "bg:ansigreen fg:ansiblack",
                    "## Set System prompt. Use j/k to move, Enter to select, Esc to cancel ",
                ),
                ("", "\n"),
            ]
            # Calculate max role length for alignment
            max_role_len = max(len(p.get_role()) for p in self.menu_state.prompts)
            for idx, prompt in enumerate(self.menu_state.prompts):
                display_text = prompt.get_role_desc(max_role_len)
                if idx == self.menu_state.selected_index:
                    style = "bg:ansiwhite fg:ansicyan bold"
                    prefix = "> "
                else:
                    style = "bg:ansiwhite fg:ansiblack"
                    prefix = "  "
                fragments.append((style, f"{prefix}{display_text} \n"))
            return fragments

        # Normal status bar
        status = []
        try:
            app = get_app()
            if app and hasattr(app, "vi_state"):
                mode_map = {
                    InputMode.INSERT: "Insert",
                    InputMode.NAVIGATION: "Normal",
                    InputMode.REPLACE: "Replace",
                }
                status.append(
                    ("InputMode", mode_map.get(app.vi_state.input_mode, "Normal"))
                )
        except:
            pass

        status.extend(
            [
                ("Tokens", format_tokens(self.state.total_tokens_consumed)),
                ("Role", self.state.current_prompt.get_role()),
                ("Model", self.state.model_name),
            ]
        )

        fragments = []
        for i, (label, value) in enumerate(status):
            fragments.append(("fg:ansiblack bg:ansicyan", f" {label}: "))
            fragments.append(("fg:ansiblack bg:ansiwhite", f"{value}"))
            if i < len(status) - 1:
                fragments.append(("fg:ansiblack bg:ansiwhite", " , "))
        return fragments


# --- Main Application ---


class ChatApp:
    """Main application logic."""

    def __init__(self, args):
        self.args = args
        self.console = Console()
        self.state = ChatState()
        self.menu_state = MenuState(ChatConfig.PROMPT_MENU)
        self.ui = ChatInterface(self.state, self.menu_state)
        self.client: Optional[ModelClient] = None

    def setup(self):
        """Initialize model and system prompt."""
        # Handle system prompt from args
        if self.args.prompt:
            if os.path.exists(os.path.expanduser(self.args.prompt)):
                self.state.current_prompt = AIPrompt(
                    role="Custom",
                    desc="Custom prompt from file",
                    rules=self.args.prompt
                )
            else:
                self.state.current_prompt = AIPrompt(
                    role="Custom",
                    desc="Custom prompt string",
                    rules=self.args.prompt
                )

        # Handle model selection
        alias = self._select_model_alias()
        try:
            self.client = ModelClient(alias)
            self.state.model_name = self.client.model_name
            self.state.llm_provider = self.client.provider
        except Exception as e:
            self.console.print(f"[red]Initialization error: {e}[/red]")
            exit(1)

        self.console.print(
            f"Welcome to [bold green]{self.state.llm_provider}:{self.state.model_name}[/bold green]!"
        )

    def _select_model_alias(self) -> str:
        if self.args.switch is True:
            self.console.print("Please select a model:")
            for a, cfg in ChatConfig.MODELS.items():
                self.console.print(f"  [bold cyan]{a}[/bold cyan]: {cfg['display']}")
            while True:
                a_in = input("Enter model alias: ").strip()
                if a_in in ChatConfig.MODELS:
                    return a_in
                self.console.print("[red]Invalid alias.[/red]")
        elif isinstance(self.args.switch, str):
            if self.args.switch in ChatConfig.MODELS:
                return self.args.switch
            self.console.print(f"[red]Unknown alias: {self.args.switch}[/red]")
            exit(1)
        return ChatConfig.DEFAULT_MODEL_ALIAS

    def run(self):
        """Main REPL loop."""
        while True:
            session = PromptSession(
                message=self.ui.get_prompt_message,
                multiline=True,
                key_bindings=self.ui.kb,
                vi_mode=True,
                wrap_lines=True,
                prompt_continuation=lambda w, l, wr: "> " if l == 0 else "  ",
                style=self.ui.style,
                bottom_toolbar=self.ui.get_status_fragments,
            )
            session.app.ttimeoutlen = 0.1

            try:
                user_input = self.args.input if self.args.input else session.prompt()
            except (KeyboardInterrupt, EOFError):
                self.console.print("\nGoodbye!")
                break

            if not user_input:
                continue

            if user_input.strip().startswith("/"):
                if self._handle_command(user_input.strip()):
                    continue

            if user_input.lower() in ["exit", "quit", "bye"]:
                break

            self._process_chat(user_input)

            if self.args.input:
                if self.args.output:
                    self._save_chat(self.args.output)
                break

    def _handle_command(self, cmd_str: str) -> bool:
        parts = cmd_str.split(maxsplit=1)
        cmd = parts[0]

        if cmd == "/new":
            self.state.reset()
            self.console.print("[bold green]New session started.[/bold green]")
            return True
        elif cmd == "/raw":
            for msg in reversed(self.state.conversation_history):
                if msg["role"] == "assistant":
                    self.console.print(
                        "\n[bold yellow]RAW:[/bold yellow]\n", msg["content"]
                    )
                    break
            return True
        elif cmd == "/copy":
            self._copy_to_clipboard(parts)
            return True
        elif cmd == "/save":
            ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            self._save_chat(f"/tmp/chat_{ts}.md")
            return True
        elif cmd == "/st" or cmd == "/status":
            self.console.print("[bold green]Status:[/bold green]")
            for label, val in [
                ("Model", self.state.model_name),
                ("Tokens", self.state.total_tokens_consumed),
                ("Prompt", f"{self.state.current_prompt.get_all()}"),
            ]:
                self.console.print(f"  [bold cyan]{label}:[/bold cyan] {val}")
            return True
        return False

    def _copy_to_clipboard(self, parts):
        try:
            import pyperclip

            if not self.state.conversation_history:
                return
            if len(parts) > 1 and parts[1].lower() == "all":
                text = "\n\n".join(
                    [
                        f"{m['role'].capitalize()}: {m['content']}"
                        for m in self.state.conversation_history
                    ]
                )
                pyperclip.copy(text)
                self.console.print("[green]Copied all.[/green]")
            else:
                for msg in reversed(self.state.conversation_history):
                    if msg["role"] == "assistant":
                        pyperclip.copy(msg["content"])
                        self.console.print("[green]Copied last.[/green]")
                        break
        except Exception as e:
            self.console.print(f"[red]Clipboard error: {e}[/red]")

    def _save_chat(self, path):
        lines = []
        for msg in self.state.conversation_history:
            role = "Question" if msg["role"] == "user" else "Answer"
            lines.append(f"\n---\n**{role}:**\n\n{msg['content']}\n")
        lines.append(
            f"\n---\nModel: **{self.state.model_name}**, "
            f"Tokens: **{format_tokens(self.state.total_tokens_consumed)}**"
        )
        try:
            with open(path, "w", encoding="utf-8") as f:
                f.writelines(lines)
            self.console.print(f"[green]Saved to {path}[/green]")
        except Exception as e:
            self.console.print(f"[red]Save error: {e}[/red]")

    def _process_chat(self, user_input: str):
        self.console.print("\n")
        self.console.rule(title="[bold magenta]Question[/bold magenta]")
        self.console.print(user_input)
        self.console.print(f"\n[bold cyan]Model:[/bold cyan] {self.state.model_name}")

        # Use a more prominent and graphical marker for the LLM response
        self.console.print("\n")
        self.console.rule(
            title="[bold bright_green]✨ ✨ 🤖 LLM 🤖 ✨ ✨[/bold bright_green]",
            style="bright_green",
            characters="━"
        )

        try:
            start_time = time.time()
            with self.console.status(
                Spinner("dots", text="[bold cyan]Waiting response ...[/bold cyan]")
            ):
                messages = [{"role": "system", "content": self.state.current_prompt.get_content()}]
                if not self.args.individual:
                    messages.extend(self.state.conversation_history)
                messages.append({"role": "user", "content": user_input})

                self.state.conversation_history.append({"role": "user", "content": user_input})

                completion = self.client.get_completion(messages, self.args.temperature)
                response = completion.choices[0].message.content or ""

                if completion.usage:
                    if self.args.individual:
                        self.state.total_tokens_consumed = completion.usage.total_tokens
                    else:
                        self.state.total_tokens_consumed += (completion.usage.total_tokens)

                self.state.conversation_history.append({"role": "assistant", "content": response})

            elapsed = time.time() - start_time
            self.console.print(
                f"[bold green]{self.state.llm_provider}:[/bold green]",
                Markdown(response),
            )
            self.console.print(
                f"\n[bold cyan]Model:[/bold cyan] {self.state.model_name}, "
                f"[bold cyan]Time:[/bold cyan] {elapsed:.2f}s, "
                f"[bold cyan]Tokens:[/bold cyan] {format_tokens(self.state.total_tokens_consumed)}"
            )
        except Exception as e:
            self.console.print(f"[red]API Error: {e}[/red]")

        self.console.rule(title="[bold magenta] End [/bold magenta]")


def main():
    parser = argparse.ArgumentParser(description="Modular LLM Chatbot")
    parser.add_argument("--prompt", help="System prompt string or file path")
    #  parser.add_argument("-c", "--cot", action="store_true", help="Enable CoT")
    parser.add_argument("-s", "--switch", nargs="?", const=True, help="Switch LLM")
    parser.add_argument("-t", "--temperature", type=float, default=0.1, help="Temperature")
    parser.add_argument("-i", "--individual", action="store_true", help="Individual mode")
    parser.add_argument("--input", type=str, help="Direct question")
    parser.add_argument("--output", type=str, help="Save output to file")
    args = parser.parse_args()

    app = ChatApp(args)
    app.setup()
    app.run()


if __name__ == "__main__":
    main()
