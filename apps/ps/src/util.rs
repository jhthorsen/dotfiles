use std::path::Path;

pub fn format_with_suffix(v: usize) -> String {
    let v = v as f64;
    const T: f64 = 1000.0 * 1000.0 * 1000.0 * 1000.0;
    const G: f64 = 1000.0 * 1000.0 * 1000.0;
    const M: f64 = 1000.0 * 1000.0;
    const K: f64 = 1000.0;

    if v >= T {
        format!("{:.0}T", v / T)
    } else if v >= G {
        format!("{:.0}G", v / G)
    } else if v >= M {
        format!("{:.0}M", v / M)
    } else if v >= K {
        format!("{:.0}k", v / K)
    } else {
        format!("{:.1}k", v / K)
    }
}

pub fn short_command(command: &str) -> String {
    let mut found_name = false;
    let mut path: Vec<String> = vec![];
    for part in command.split(" ") {
        if found_name {
            path.push(part.to_string());
        } else {
            path.push(part.to_string());
            if Path::new(&path.join(" ")).is_file() {
                path.clear();
                path.push(part.split("/").last().unwrap().to_string());
                found_name = true;
            }
        }
    }

    path.join(" ").to_string()
}

#[cfg(test)]
mod tests {
    use super::{format_with_suffix, short_command};

    #[test]
    fn all_format_with_suffix() {
        assert_eq!(format_with_suffix(0), "0.0k".to_string());
        assert_eq!(format_with_suffix(1), "0.0k".to_string());
        assert_eq!(format_with_suffix(10), "0.0k".to_string());
        assert_eq!(format_with_suffix(200), "0.2k".to_string());
        assert_eq!(format_with_suffix(3000), "3k".to_string());
        assert_eq!(format_with_suffix(400000), "400k".to_string());
        assert_eq!(format_with_suffix(50000000), "50M".to_string());
        assert_eq!(format_with_suffix(6000000000), "6G".to_string());
        assert_eq!(format_with_suffix(71123456789000), "71T".to_string());
    }

    #[test]
    fn short_command_simple() {
        assert_eq!(short_command("/bin/ps axf -o comm"), "ps axf -o comm".to_string());
    }
}
