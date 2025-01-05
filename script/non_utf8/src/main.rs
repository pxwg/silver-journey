use std::collections::HashSet;
use std::env;
use std::str;

fn clean_string(input: &str) -> String {
    let allowed_symbols: HashSet<char> = ".,!?，。！？()[] /\\'\"+\\-{}*^%$#@!&_".chars().collect();
    let mut result = String::new();
    let mut is_line_start = true;

    for c in input.chars() {
        if c.is_alphanumeric() || allowed_symbols.contains(&c) {
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
    let cleaned = match str::from_utf8(input.as_bytes()) {
        Ok(valid_str) => clean_string(valid_str),
        Err(_) => {
            eprintln!("Error: Input string is not valid UTF-8");
            std::process::exit(1);
        }
    };
    println!("{}", cleaned);
}
