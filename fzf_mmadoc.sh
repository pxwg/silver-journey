#!/bin/bash

# 检查是否提供了文件名作为参数
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

# 切换到指定路径
cd /Library/Wolfram/Documentation/14.1/zh-hans-cn/Documentation/ChineseSimplified/ || exit

# 使用 find 命令搜索文件并输出第一个结果
result=$(find . -type f -name "$1" | head -n 1)

# 检查是否找到文件
if [ -z "$result" ]; then
  echo "No file found matching '$1'"
  exit 1
fi

# 输出找到的文件路径
echo "Found file: $result"

# 打开找到的文件
open "$result"
