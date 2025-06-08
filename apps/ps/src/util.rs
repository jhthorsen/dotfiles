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
