#/bin/sh

# use expect to write password information from STDIN

exec expect -f "$0" ${1+"$@"}
set password [lindex $argv 1]
spawn passwd [lindex $argv 0]

sleep 1

expect "assword:"
send "$password\r"

expect "assword:"
send "$password\r"

expect eof

