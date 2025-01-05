use std::collections::HashSet;
use std::env;
use std::fs::File;
use std::io::{self, BufRead};

fn load_chinese_char_map(file_path: &str) -> io::Result<Vec<String>> {
    let mut char_list = Vec::new();
    let file = File::open(file_path)?;
    let reader = io::BufReader::new(file);

    for line in reader.lines() {
        let line = line?;
        let parts: Vec<&str> = line.split(" --->").collect();
        if parts.len() == 2 {
            let value = parts[1].trim().to_string();
            char_list.push(value);
        }
    }

    Ok(char_list)
}

fn clean_string(input_str: &str, chinese_char_map: &[String]) -> String {
    let allowed_chars: HashSet<char> = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?，。！？()[] /\\'\"+-{}*^%$#@!&_=\n"
        .chars()
        .collect();
    let chinese_char_set: HashSet<&str> = chinese_char_map.iter().map(|s| s.as_str()).collect();
    let mut result = String::new();
    let mut is_line_start = true;

    for c in input_str.chars() {
        if allowed_chars.contains(&c) || chinese_char_set.contains(&c.to_string().as_str()) {
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

    let input_str = &args[1];
    let chinese_char_map =
        load_chinese_char_map("/Users/pxwg-dogggie/.config/nvim/script/non_utf8/src/cn-utf8.txt")
            .expect("Failed to load Chinese character map");
    let cleaned = clean_string(input_str, &chinese_char_map);
    println!("{}", cleaned);

    // let duration = start.elapsed();
    // println!("Time elapsed: {:?}", duration);
}
