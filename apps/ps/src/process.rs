#[derive(Clone, Debug)]
pub struct Process {
    pub pid: u32,
    pub ppid: u32,
    pub columns: Option<Vec<String>>,
    pub children: Vec<u32>,
}

impl Process {
    pub fn from_line(line: &str, headers: &Vec<&str>) -> Option<Self> {
        let parts = line.split_whitespace().collect::<Vec<&str>>();
        if parts.len() < headers.len() {
            return None;
        }

        let Ok(pid) = parts[0].parse::<u32>() else {
            return None;
        };

        let Ok(ppid) = parts[1].parse::<u32>() else {
            return None;
        };

        let mut columns = vec![];
        let mut rest: Vec<String> = parts[2..].iter().map(|s| s.to_string()).collect();
        while columns.len() < headers.len() - 3 {
            columns.push(rest.remove(0));
        }

        columns.push(rest.join(" "));

        Some(Process {
            pid,
            ppid,
            columns: Some(columns),
            children: vec![],
        })
    }
}
