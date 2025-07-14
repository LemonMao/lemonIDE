#!/usr/bin/env python3
import os
import re
import argparse
from argparse import RawDescriptionHelpFormatter
import gzip
from datetime import datetime, timezone
from glob import glob


# Usage:
# Step-1: Mount savelogs_after_test into local.
# > sudo mount -t nfs durbiox.west.isilon.com:/ifs/qa/log/QA_test_results/BR_LEMON_MAO_PSCALE_252847/B_LEMON_MAO_PSCALE_252847_003-RELEASE/auth_mvt.list.ON.lmao-gvo4zty/TM_20250212_16_13_28/savelogs_after_test ~/tmp/qa_log
#
# Step-2: Collect each nodes logs from lmao-gvo4zty-*/varlog.tar/log/lwsmd*
#         within a specified time range.
# > ilogv2.py -u lmao -p ~/qa_log/ 2025-02-13T00:38:41 2025-02-13T00:38:51 lwsmd.log > /tmp/1.log
#
# > ilogv2.py -u lmao -p ~/qa_log/ 2025-02-13T00:38:41.014481+00:00 2025-02-13T00:38:51.370152+00:00 lwsmd.log > /tmp/1.log
def parse_args():
    parser = argparse.ArgumentParser(
        description="Collect logs within a specified time range.\n\nUsage examples:\n\
        sudo mount -t nfs host:/ifs/qa/log ~/tmp/qa_log\n\
        ilogv -u lmao -p ~/qa_log/ 2025-02-13T00:38:41 2025-02-13T00:38:51 lwsmd.log > /tmp/1.log",
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "-u",
        dest="user",
        default=os.getenv("USER"),
        help="User to search for node directories (default: $USER), e.g., -u lmao",
    )
    parser.add_argument(
        "-p",
        dest="path",
        default=".",
        help='Root path to search for node directories (default: ".")',
    )
    parser.add_argument(
        "start", help="Start datetime in ISO format (YYYY-MM-DDTHH:MM:SS)"
    )
    parser.add_argument("end", help="End datetime in ISO format (YYYY-MM-DDTHH:MM:SS)")
    parser.add_argument(
        "logname", help="Name of the log file to process (e.g., lwsmd.log)"
    )
    args = parser.parse_args()
    return args


def find_node_dirs(root, user):
    pattern = re.compile(rf"^{user}-[a-zA-Z0-9]+-\d+$")
    return [
        d
        for d in os.listdir(root)
        if pattern.match(d) and os.path.isdir(os.path.join(root, d))
    ]


def process_log_file(fpath, start_dt, end_dt):
    logs = []
    opener = gzip.open if fpath.endswith(".gz") else open
    stop_process = False
    with opener(fpath, "rt") as f:
        for line in f:
            if not line.strip():
                continue
            ts_str = line.split()[0]
            try:
                ts = datetime.fromisoformat(ts_str).replace(tzinfo=timezone.utc)
                if start_dt <= ts <= end_dt:
                    logs.append((ts, line.strip()))
                elif ts < start_dt:
                    stop_process = True
                elif ts > end_dt:
                    break
            except (ValueError, IndexError):
                continue
    return logs, stop_process


def main():
    args = parse_args()
    start_dt = datetime.fromisoformat(args.start).replace(tzinfo=timezone.utc)
    end_dt = datetime.fromisoformat(args.end).replace(tzinfo=timezone.utc)

    all_logs = []
    node_dirs = sorted(
        find_node_dirs(args.path, args.user), key=lambda x: int(x.split("-")[-1])
    )

    for node in node_dirs:
        log_dir = os.path.join(args.path, node, "varlog.tar", "log")
        if not os.path.exists(log_dir):
            continue

        node_logs = []
        pattern = os.path.join(log_dir, f"{args.logname}*")
        files = glob(pattern)
        files.sort()
        stop_process = False
        print(f"Found {len(files)} files: {files}")
        for fpath in files:
            if stop_process:
                # print('-- Stop process!')
                break
            print(f"Processing: {fpath}")
            #  if fpath.endswith((".log", ".gz")):
            processed, stop_process = process_log_file(fpath, start_dt, end_dt)
            node_logs.extend(processed)
            #  else:
            #      print(f"Skip unknown file type: {fpath}")

        node_logs.sort()
        print(f"#-------{node}：")
        for ts, line in node_logs:
            print(line)
        all_logs.extend(node_logs)

    print("\n\n############## -- Cluster")
    for ts, line in sorted(all_logs):
        print(line)


if __name__ == "__main__":
    main()
