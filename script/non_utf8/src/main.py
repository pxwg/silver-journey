import sys
import os

def load_chinese_char_map(file_path):
    char_list = []
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            parts = line.split(" --->")
            if len(parts) == 2:
                value = parts[1].strip()
                char_list.append(value)
    return char_list

# print(load_chinese_char_map("/Users/pxwg-dogggie/.config/nvim/script/non_utf8/src/cn-utf8.txt"))

def clean_string(input_str, chinese_char_map):
    allowed_chars = set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?，。！？()[] /\\'\"+-{}*^%$#@!&_")
    result = []
    is_line_start = True

    for c in input_str:
        if c in allowed_chars or c in chinese_char_map:
            result.append(c)
            is_line_start = False
        else:
            if is_line_start:
                continue
            else:
                break

    return ''.join(result)

def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <string>", file=sys.stderr)
        sys.exit(1)

    input_str = sys.argv[1]
    chinese_char_map = load_chinese_char_map("/Users/pxwg-dogggie/.config/nvim/script/non_utf8/src/cn-utf8.txt")
    cleaned = clean_string(input_str, chinese_char_map)
    print(cleaned)

if __name__ == "__main__":
    main()
