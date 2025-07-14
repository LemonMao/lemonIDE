#!/usr/bin/env python3
#########################################################
# Call Stack Graph Generator Tool Documentation
#########################################################
#
# 1. Command Option Introduction:
#
#   --codebase <path>         Path to the C codebase. Required.
#   --start <function>        Starting function in format 'filename:function_name' or 'function_name'. Required.
#                             If filename is provided, it gives more context for the starting point.
#   --depth <int>             Maximum depth of call stack. Optional. No limit if not specified.
#   --mermaid                 Generate Mermaid code from call stack JSON. Optional.
#   --svg                     Generate SVG image from call stack JSON. Optional. Requires Graphviz 'dot' command.
#   --chat                    Call 'chat --prompt' with call stack JSON. Optional. Requires 'chat' command in PATH.
#   -d, --debug               Enable debug logging. Optional.
#
# 2. Usage Example:
#
#   Example 1: Generate call stack JSON for function 'main' in codebase '/path/to/codebase' with depth 3:
#      python callGraph.py --codebase /path/to/codebase --start main --depth 3
#
#   Example 2: Generate Mermaid code for function 'entry_point' in 'src/main.c' in codebase '/path/to/codebase':
#      python callGraph.py --codebase /path/to/codebase --start src/main.c:entry_point --mermaid
#
# 3. Dependency Install:
#
#   - global (GNU Global): Required for C code indexing and function definition lookup.
#     Install via your system's package manager (e.g., 'sudo apt install global' on Debian/Ubuntu, 'brew install global' on macOS).
#     Ensure 'gtags' and 'global' commands are in your PATH.
#   - Graphviz (dot command): Required for generating SVG images (--svg option).
#     Install via your system's package manager (e.g., 'sudo apt install graphviz' on Debian/Ubuntu, 'brew install graphviz' on macOS).
#   - Gemini API Key: Required for generating Mermaid code (--mermaid option).
#     Set the environment variable GEMINI_API_KEY with your Gemini API key.
#     Follow Google Gemini API setup instructions to obtain an API key.
#   - pycparser: Required for parsing C code (though currently not heavily used in this version).
#     Install via pip: 'pip install pycparser'
#
#########################################################

import argparse
import subprocess
import json
import os
import re
import google.generativeai as genai
import time
from pycparser import CParser, c_ast
import io

#########################################################
# call stack graph
#########################################################
filter_strings = [
    "LSA_LOG",
    "assert",
    "BAIL_ON_",
    "_LOG_",
]  # Define filter strings here, case-insensitive

def check_gtags(codebase_path):
    """Checks if GTAGS file exists in the codebase and updates it incrementally."""
    gtags_path = os.path.join(codebase_path, "GTAGS")
    if os.path.exists(gtags_path):
        print("GTAGS file found. Updating incrementally...")
        try:
            command_str = f"cd {codebase_path} && gtags --incremental --skip-unreadable"
            process = subprocess.run(command_str, shell=True, capture_output=True, text=True, check=True)
            print("GTAGS updated incrementally.")
            if process.stderr:
                print(f"GTAGS update stderr: {process.stderr}") # print stderr if any, but not critical
        except subprocess.CalledProcessError as e:
            raise Exception(f"Error updating GTAGS incrementally: {e.stderr}")
        except FileNotFoundError:
            raise Exception("Error: 'gtags' command not found. Please ensure 'global' is installed and in your PATH.")

    else:
        raise Exception("GTAGS file not found in the codebase. Please generate GTAGS using 'global' command in the codebase root directory (e.g., 'cd {}; global --gtags .').".format(codebase_path))

def get_function_definition(symbol_name, codebase_path):
    """Uses 'global -x' to get function definition."""
    try:
        command = ["global", "-x", symbol_name]
        process = subprocess.run(command, cwd=codebase_path, capture_output=True, text=True, check=True)
        output_line = process.stdout.strip()
        if not output_line:
            return None  # Symbol definition not found

        parts = output_line.split()
        if len(parts) < 4: # Ensure we have enough parts to unpack
            return None # malformed output

        symbol_name_from_global = parts[0]
        line_num = parts[1]
        file_path = parts[2]
        definition_line = " ".join(parts[3:])


        # Extract full definition from file
        full_definition = ""
        try:
            with open(os.path.join(codebase_path, file_path), 'r') as f:
                lines = f.readlines()
                start_line_index = int(line_num) - 1
                definition_block = ""

                if start_line_index < len(lines):
                    definition_block += lines[start_line_index].strip()

                    brace_count = definition_block.count('{') - definition_block.count('}')
                    current_line_index = start_line_index + 1
                    while brace_count >= 0 and current_line_index < len(lines):
                        line = lines[current_line_index].strip()
                        definition_block += "\n" + line
                        brace_count += line.count('{') - line.count('}')
                        current_line_index += 1
                        if brace_count == 0 and '}' in line: #stop at first closing brace
                            break


                full_definition = definition_block

        except Exception as e:
            print(f"Error reading file {file_path} to extract full definition: {e}")
            full_definition = definition_line # fallback to single line if file read error

        return {
            "symbol_name": symbol_name_from_global,
            "definition": full_definition.strip()
        }
    except subprocess.CalledProcessError as e:
        if "No matches for" in e.stderr:
            return None # Symbol definition not found (global returns error if not found)
        else:
            raise Exception(f"Error executing 'global -x': {e.stderr}")
    except FileNotFoundError:
        raise Exception("Error: 'global' command not found. Please ensure 'global' is installed and in your PATH.")


def get_called_functions(definition):
    """Parses function definition to find called functions (very basic parsing)."""
    function_calls = []
    # Very simple regex to find potential function calls: word followed by '('
    # This is a simplification and might need to be more robust for complex C code.
    pattern = r"(\w+)\s*\("
    matches = re.findall(pattern, definition)
    for match in matches:
        if match not in ["if", "else", "for", "while", "switch", "return", "case", "default"]: # filter out keywords
            function_calls.append(match + "()") # Add parenthesis back to represent function call

    return function_calls

def generate_call_stack(start_function_name, start_file_path, codebase_path, depth, current_depth=1, visited_functions=None, debug=False):
    """Recursively generates the call stack with depth control."""

    if debug:
        print(f"[DEBUG] generate_call_stack: start_function_name={start_function_name}, start_file_path={start_file_path}, depth={depth}, current_depth={current_depth}")

    if visited_functions is None:
        visited_functions = set()

    if start_function_name in visited_functions:
        if debug:
            print(f"[DEBUG] generate_call_stack: Already visited {start_function_name}, skipping recursion.")
        return None  # Avoid infinite recursion

    if depth is not None and current_depth > depth:
        if debug:
            print(f"[DEBUG] generate_call_stack: Max depth reached at {start_function_name}, skipping deeper recursion.")
        return None

    visited_functions.add(start_function_name)

    function_info = get_function_definition(start_function_name, codebase_path) # use get_function_definition

    if function_info is None:
        if debug:
            print(f"[DEBUG] generate_call_stack: Definition not found for {start_function_name}, skipping.")
        return None # Skip if definition not found

    current_cs = {
        "function_name": function_info["symbol_name"], # rename from function_name to symbol_name
        "definition": function_info["definition"],
        "invoke_functions": []
    }

    called_function_names = get_called_functions(function_info["definition"])
    if debug:
        print(f"[DEBUG] generate_call_stack: Called functions in {start_function_name}: {called_function_names}")

    for called_func_name_call in called_function_names:
        called_func_name = called_func_name_call[:-2] # remove "()" to pass to global

        # Apply filter
        filtered_out = False
        for filter_str in filter_strings:
            if filter_str.lower() in called_func_name.lower():
                if debug:
                    print(f"[DEBUG] generate_call_stack: Function '{called_func_name}' filtered out because it contains '{filter_str}'.")
                filtered_out = True
                break
        if filtered_out:
            continue # Skip to next function if filtered

        called_func_info = get_function_definition(start_function_name, codebase_path) # try to find definition in codebase

        if called_func_info: # Found definition of called function, recursively process it
            if debug:
                print(f"[DEBUG] generate_call_stack: Found definition for called function {called_func_name}, recursive call...")
            recursive_cs = generate_call_stack(called_func_name, None, codebase_path, depth, current_depth + 1, visited_functions, debug)
            if recursive_cs: # if recursive call returns a CS (not skipped)
                current_cs["invoke_functions"].append(recursive_cs)
        else:
            if debug:
                print(f"[DEBUG] generate_call_stack: Definition not found for called function {called_func_name}, skipping recursive call.")


    return current_cs


def print_directory_tree(codebase_path):
    """Prints the directory tree using the 'tree' command."""
    try:
        command = f"cd {codebase_path} && /usr/bin/tree"
        process = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
        print("Project Directory Tree:")
        print(process.stdout)
    except FileNotFoundError:
        print("Warning: 'tree' command not found. Directory tree listing will be skipped.")
    except subprocess.CalledProcessError as e:
        print(f"Error executing 'tree' command: {e.stderr}")


def generate_mermaid_code(call_stack_json_str):
    """Generates Mermaid code from call stack JSON using Gemini API."""
    gemini_api_key = os.environ.get("GEMINI_API_KEY")
    if not gemini_api_key:
        raise EnvironmentError("GEMINI_API_KEY environment variable not set. Required for Mermaid code generation.")

    genai.configure(api_key=gemini_api_key)
    model = genai.GenerativeModel('gemini-2.0-flash')

    prompt_text = f"""
    I have the call stack json like below. Draw the call graph to me with Mermaid. Just give the code, no explain.
    The Mermaid format is like:

    ```Mermaid
    graph TD
        main("main():<br>($summary_of_functiom)") --> func1("func1():<br>($summary_of_functiom)")
    ```
    `$summary_of_functiom` is the summary the functions's uage like what's it and what does it do.

    Mermaid Restrictions:
    1. Double quotes including double quotes are not allowed. Like:  "\"<null>\"" should be changed to "<null>".

    ```json {call_stack_json_str} ```
    """
    try:
        response = model.generate_content(prompt_text)
        mermaid_code = response.text
        return mermaid_code
    except Exception as e:
        raise Exception(f"Error generating Mermaid code with Gemini API: {e}")

def json_to_dot(json_data, dot_string='', parent_function_name=None):
    """
    Recursively converts JSON call stack data to Graphviz DOT language.

    Args:
        json_data (dict): JSON data representing a function and its calls.
        dot_string (str): Accumulating DOT language string.
        parent_function_name (str): Name of the parent function (for edges).

    Returns:
        str: Updated DOT language string.
    """
    function_name = json_data['function_name']

    # Create a node label with function name only
    node_label = f"{function_name}"
    dot_string += f'    "{function_name}" [label="{node_label}"];\n'

    if parent_function_name:
        dot_string += f'    "{parent_function_name}" -> "{function_name}";\n'

    for invoked_func in json_data.get('invoke_functions', []):
        dot_string = json_to_dot(invoked_func, dot_string, function_name)

    return dot_string

def create_svg_from_json(json_input, output_file="/tmp/call_stack.svg"):
    """
    Converts JSON call stack data to an SVG image using Graphviz.

    Args:
        json_input (str or dict): JSON string or dictionary of the call stack.
        output_file (str): The name of the output SVG file.
    """
    if isinstance(json_input, str):
        data = json.loads(json_input)
    else:
        data = json_input

    dot_content = "digraph call_stack {\n"
    dot_content += "    node [shape=box];\n" # Style for nodes
    dot_content = json_to_dot(data, dot_content)
    dot_content += "}\n"

    try:
        # Execute the dot command to generate SVG
        process = subprocess.Popen(
            ['dot', '-Tsvg', '-o', output_file],
            stdin=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        stdout, stderr = process.communicate(input=dot_content.encode('utf-8'))

        if stderr:
            print(f"Error generating SVG:\n{stderr.decode()}")
        else:
            print(f"SVG image generated successfully: {output_file}")

    except FileNotFoundError:
        print("Error: Graphviz 'dot' command not found. Make sure Graphviz is installed and in your PATH.")
    except Exception as e:
        print(f"An error occurred: {e}")


def main():
    parser = argparse.ArgumentParser(description="Generate Call Stack JSON for a C project.")
    parser.add_argument("--codebase", required=True, help="Path to the C codebase")
    parser.add_argument("--start", required=True, help="Starting point function in format 'filename:function_name'")
    parser.add_argument("--depth", type=int, default=None, help="Maximum depth of call stack. No limit if not specified.")
    parser.add_argument("--mermaid", action="store_true", help="Generate Mermaid code from call stack JSON")
    parser.add_argument("--svg", action="store_true", help="Generate SVG image from call stack JSON")
    parser.add_argument("--chat", action="store_true", help="Call 'chat --prompt' with call stack JSON")
    parser.add_argument("-d", "--debug", action="store_true", help="Enable debug logging")

    args = parser.parse_args()

    codebase_path = os.path.expanduser(args.codebase) # handle ~ in path
    start_arg = args.start.split(":")
    start_file_name = None  # Initialize filename as None
    symbol_name = ""

    if len(start_arg) == 2:
        file_path_part, symbol_part = start_arg
        start_file_name = file_path_part  # Filename is provided
        symbol_name = symbol_part
    elif len(start_arg) == 1:
        symbol_name = start_arg[0]
    else:
        parser.error("Invalid --start format. Please use 'filename:symbol'")

    if symbol_name.endswith("()"):
        symbol_name = symbol_name[:-2] # remove "()" only if it ends with "()"
    start_symbol_name = symbol_name # rename for clarity, either function or class name


    print(f"Start function: '{start_symbol_name}', file: '{start_file_name}'") # debug log

    if not os.path.exists(codebase_path):
        parser.error(f"Codebase path '{codebase_path}' does not exist.")

    try:
        check_gtags(codebase_path)
    except Exception as e:
        print(f"Error: {e}")
        return

    # print_directory_tree(codebase_path)

    graph_json = generate_call_stack(start_symbol_name, None, codebase_path, depth=args.depth, debug=args.debug)

    if graph_json:
        # Dump JSON to file
        timestamp = str(int(time.time()))
        json_file_path = f"/tmp/call_stack_{timestamp}.json"
        role_prompt = f"Following is function call stack with json format. Works as a programmer to give more detail description in code level.\n"
        with open(json_file_path, 'w') as f:
            f.write(role_prompt)
            json.dump(graph_json, f, indent=4)
        file_size_bytes = os.path.getsize(json_file_path)
        file_size_kb = file_size_bytes / 1024.0
        print(f"Call stack JSON dumped to: {json_file_path} ({file_size_kb:.2f} KB)")

        if args.mermaid:
            mermaid_code = ""
            try:
                mermaid_code = generate_mermaid_code(json.dumps(graph_json)) # use graph_json here
                print("\nMermaid Code (Call Stack Mindmap):", mermaid_code)
            except Exception as e:
                print(f"Error generating Mermaid code: {e}")
        elif args.svg:
            try:
                output_svg = f"/tmp/call_stack_{timestamp}.svg"
                create_svg_from_json(graph_json, output_svg) # use graph_json here
            except Exception as e:
                print(f"Error generating SVG image: {e}")
        #  else:
        #      print("\nCall stack JSON:")
        #      call_stack_json_str = json.dumps(graph_json, indent=4)
        #      print(call_stack_json_str)

        if args.chat:
            try:
                command_str = f"chat --prompt {json_file_path}"
                print(f"\n\nExecuting chat command: {command_str}")
                process = subprocess.run(command_str, shell=True, check=True)
            except subprocess.CalledProcessError as e:
                print(f"Error executing chat command: {e}")
            except KeyboardInterrupt:
                print("\nQuit.")
    else:
        print(f"Could not generate graph starting from {args.start}. Definition of start symbol '{start_symbol_name}' might not be found.")


if __name__ == "__main__":
    main()
