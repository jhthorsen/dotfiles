#[derive(Clone, Debug)]
pub struct Process {
    pub pid: u32,
    pub ppid: u32,
    pub columns: Vec<String>,
    pub last: String,
    pub children: Vec<u32>,
}

impl Process {
    pub fn from_line(line: &str, headers: &Vec<String>) -> Option<Self> {
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
            last: columns.pop().unwrap_or_default(),
            columns: columns,
            children: vec![],
        })
    }
}

#[cfg(test)]
mod tests {
    use super::Process;

    #[test]
    fn empty() {
        let p = Process::from_line("", &vec!["a".to_string(), "b".to_string()]);
        assert!(p.is_none());
    }

    #[test]
    fn too_short() {
        let p = Process::from_line("a", &vec!["a".to_string(), "b".to_string()]);
        assert!(p.is_none());
    }

    #[test]
    fn without_columns() {
        let p = Process::from_line(
            "29772 23663 /bin/bash --login",
            &vec!["pid".to_string(), "ppid".to_string(), "comm".to_string()],
        );
        assert!(p.is_some());

        let Some(p) = p else { return };
        assert_eq!(p.pid, 29772);
        assert_eq!(p.ppid, 23663);
        assert_eq!(p.columns, Vec::<String>::new());
        assert_eq!(p.last, "/bin/bash --login".to_string());
        assert_eq!(p.children, vec![]);
    }

    #[test]
    fn with_columns() {
        let p = Process::from_line(
            "29772 23663 superwoman /bin/bash --login",
            &vec![
                "pid".to_string(),
                "ppid".to_string(),
                "user".to_string(),
                "comm".to_string(),
            ],
        );
        assert!(p.is_some());

        let Some(p) = p else { return };
        assert_eq!(p.pid, 29772);
        assert_eq!(p.ppid, 23663);
        assert_eq!(
            p.columns,
            Vec::<String>::from(vec!["superwoman".to_string()])
        );
        assert_eq!(p.last, "/bin/bash --login".to_string());
        assert_eq!(p.children, vec![]);
    }
}
