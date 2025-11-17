#!/usr/bin/env python3


import argparse
import pyautogui
import time

def run_mouse_script(duration_minutes):
    """
     运行鼠标脚本，持续指定分钟数。

     Args:
         duration_minutes: 脚本运行的总分钟数。
     """
    start_time = time.time()
    end_time = start_time + duration_minutes * 60  # 计算结束时间 (秒)

    if duration_minutes < 60:
        duration_str = f"{duration_minutes} 分钟"
    else:
        duration_hours = duration_minutes / 60
        duration_str = f"{duration_hours:.1f} 小时" # 保留一位小数

    print(f"脚本将运行 {duration_str}。")
    print("请不要移动鼠标，脚本将在后台运行。")
    print("可以通过关闭终端窗口或强制结束Python进程来停止脚本。")
    move_offset = 100  # 鼠标移动的像素距离，可以根据需要调整

    while time.time() < end_time:
        start_interval_time = time.time()

        # 1. 向上移动一小格
        print("Move up")
        current_x, current_y = pyautogui.position()
        pyautogui.moveRel(0, -move_offset)  # 相对当前位置移动

        time.sleep(1)

        # 2. 向下移动一小格 (回到原位)
        print("Move down")
        pyautogui.moveRel(0, move_offset)

        time.sleep(1)

        # 3. 点击鼠标左键
        print("Click")
        pyautogui.click()

        time.sleep(10)

    print("脚本运行结束。")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="运行鼠标点击脚本，可以指定持续时间。")
    parser.add_argument(
        "-d",
        "--duration",
        type=int,
        default=300,
        help="脚本运行的持续时间，单位为分钟。默认 300 分钟。",
    )
    args = parser.parse_args()
    run_mouse_script(args.duration)
