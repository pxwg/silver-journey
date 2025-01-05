use std::collections::{HashMap, HashSet};
use std::env;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

fn load_chinese_char_map(file_path: &str) -> io::Result<HashMap<char, char>> {
    let path = Path::new(file_path);
    println!("Loading Chinese character map from: {:?}", path); // 打印文件路径
    let file = File::open(&path)?;
    let reader = io::BufReader::new(file);

    let mut char_map = HashMap::new();

    for line in reader.lines() {
        let line = line?;
        let parts: Vec<&str> = line.split(" --->").collect();
        if parts.len() == 2 {
            let key = parts[0].trim();
            let value = parts[1].trim();

            // 解析 Unicode 转义字符
            if let (Ok(key_char), Some(value_char)) =
                (parse_unicode_escape(key), value.chars().next())
            {
                char_map.insert(key_char, value_char);
            }
        }
    }

    Ok(char_map)
}

fn parse_unicode_escape(unicode_escape: &str) -> Result<char, ()> {
    if unicode_escape.starts_with("\\U") {
        let hex = &unicode_escape[2..];
        if let Ok(code_point) = u32::from_str_radix(hex, 16) {
            if let Some(c) = std::char::from_u32(code_point) {
                return Ok(c);
            }
        }
    }
    Err(())
}

fn clean_string(input: &str, chinese_char_map: &HashMap<char, char>) -> String {
    let allowed_chars: HashSet<char> = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?，。！？()[] /\\'\"+\\-{}*^%$#@!&_".chars().collect();
    let mut result = String::new();
    let mut is_line_start = true;

    for c in input.chars() {
        if allowed_chars.contains(&c) || chinese_char_map.contains_key(&c) {
            result.push(c);
            is_line_start = false;
        } else {
            if is_line_start {
                continue;
            } else {
                break;
            }
        }
    }

    result
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <string>", args[0]);
        std::process::exit(1);
    }

    let input = &args[1];
    let chinese_char_map =
        load_chinese_char_map("/Users/pxwg-dogggie/.config/nvim/script/non_utf8/src/cn-utf8.txt")
            .expect("Failed to load Chinese character map");
    let cleaned = clean_string(input, &chinese_char_map);
    println!("{}", cleaned);
}
