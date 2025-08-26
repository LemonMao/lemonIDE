import xml.dom.minidom
from colorama import Fore, Style
import subprocess
import sys, os
import shutil


def pretty_print_xml(xml_string):
    # parse the xml string
    xml_dom = xml.dom.minidom.parseString(xml_string)
    # get the pretty printed xml string
    pretty_xml_string = xml_dom.toprettyxml()
    # split the pretty printed xml string into lines
    lines = pretty_xml_string.split('\n')
    # create a new list to store the colored lines
    colored_lines = []
    # iterate over the lines
    for line in lines:
        # if the line contains an opening or closing tag
        if '<' in line or '>' in line:
            # split the line into parts
            parts = line.split(' ')
            # iterate over the parts
            for i in range(len(parts)):
                # if the part starts with '<', it is a tag
                if parts[i].startswith('<'):
                    # color the tag
                    parts[i] = Fore.YELLOW + parts[i] + Style.RESET_ALL
                # if the part ends with '>', it is the end of a tag
                elif parts[i].endswith('>'):
                    # color the end of the tag
                    parts[i] = parts[i][:-1] + Fore.YELLOW + '>' + Style.RESET_ALL
                # if the part contains an attribute
                elif '=' in parts[i]:
                    # split the attribute into parts
                    attr_parts = parts[i].split('=')
                    # iterate over the attribute parts
                    for j in range(len(attr_parts)):
                        # if the part is the attribute name
                        if j % 2 == 0:
                            # color the attribute name
                            attr_parts[j] = Fore.GREEN + attr_parts[j] + Style.RESET_ALL
                        # if the part is the attribute value
                        else:
                            # color the attribute value
                            attr_value = attr_parts[j].strip("=").strip('"')
                            attr_parts[j] = '=' + Fore.RED + '"' + attr_value + '"' + Style.RESET_ALL
                    # join the attribute parts back together
                    parts[i] = ''.join(attr_parts)
            # join the parts back together
            colored_line = ' '.join(parts)
            # add the colored line to the list of colored lines
            colored_lines.append(colored_line)
        # otherwise, just add the line to the list of colored lines
        else:
            colored_lines.append(line)
    # join the colored lines back together
    colored_xml_string = '\n'.join(colored_lines)
    # return the colored xml string
    return colored_xml_string

def interactive_git_diff(commit):
    """"""
    # gitdiffcmd="git d -y"
    # tmp_file="/tmp/temp_lt_gitdiff_1234.txt"

    # if commit is None or commit in ('', '.'):
        # subprocess.run(['git', 'status'])
        # print("Choose diff between regions.")
        # ret = input("w:work<->stage, s:stage<->commit, c:work<->commit [W/s/c] : ")
        # if ret.lower() in ('w', ''):
            # gitdiffcmd="git d -y"
        # elif ret.lower() == 's':
            # gitdiffcmd="git d -y  --staged"
        # elif ret.lower() == 'c':
            # gitdiffcmd="git d -y  HEAD"

        # # write git status to file
        # with open(tmp_file, 'w') as f:
            # result = subprocess.run(['git', 'status', '-s'], stdout=subprocess.PIPE)
            # f.write(result.stdout.decode())
        # with open('/tmp/mss-ci-diff', 'w') as f:
            # result = subprocess.run(['git', 'status', '-s'], stdout=subprocess.PIPE)
            # f.write('Index\tName\tStatus\n')
            # for i, line in enumerate(result.stdout.decode().splitlines()):
                # parts = line.split()
                # f.write(f'{i}\t{parts[0]}\t{parts[1]}\n')
    # else:
        # # Index diff old -- new
        # subprocess.run(['git', 'log', '-1', commit])
        # # todo: please consider the merge branch which have two parrents.
        # # git log --name-status -1 --pretty=format:"%p %h" $commit | grep -v "$commit" > $tmp_file
        # result = subprocess.run(['git', 'diff', '--name-status', f'{commit}^', commit], stdout=subprocess.PIPE)
        # with open(tmp_file, 'w') as f:
            # f.write(result.stdout.decode())
        # with open('/tmp/mss-ci-diff', 'w') as f:
            # f.write('Index\tStatus\tName\n')
            # for i, line in enumerate(result.stdout.decode().splitlines()):
                # f.write(f'{i}\t{line}\n')
        # gitdiffcmd=f"git d -y {commit}^ {commit}"


    return

def decompress(file_path):
    # extract the compressed file
    # os.path.splitext(file_path)[0]
    shutil.unpack_archive(file_path)
    print(f"{file_path} extracted successfully!")


def extract_logs_by_time_range(file_path, start_dt, end_dt):
    """Extract logs from a file within the specified time range."""
    import gzip
    from datetime import datetime, timezone
    import re

    # Open the file (handle gzipped files)
    opener = gzip.open if file_path.endswith(".gz") else open

    logs = []
    timestamp_pattern = re.compile(r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:[+-]\d{2}:\d{2}|Z)?)')

    try:
        with opener(file_path, 'rt') as f:
            for line in f:
                if not line.strip():
                    continue

                # Try to extract timestamp from the beginning of the line
                match = timestamp_pattern.match(line)
                if match:
                    ts_str = match.group(1)
                    try:
                        # Handle different timestamp formats
                        if ts_str.endswith('Z'):
                            ts_str = ts_str[:-1] + '+00:00'
                        ts = datetime.fromisoformat(ts_str).replace(tzinfo=timezone.utc)

                        if start_dt <= ts <= end_dt:
                            logs.append(line.strip())
                        elif ts > end_dt:
                            break  # Stop processing if we're past the end time
                    except ValueError:
                        # If timestamp parsing fails, skip this line
                        continue
    except Exception as e:
        print(f"Error processing file {file_path}: {e}")
        return []

    return logs
