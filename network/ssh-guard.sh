#!/bin/sh

man() {
    cat <<'MAN'
NAME
    Socks daemon - Keep connected with Socks/SSH

SYNOPSIS
    $ socks-daemon.sh; # show help
    $ socks-daemon.sh "-D 8888 some-host.com"

DESCRIPTION
   This script will start SSH as a daemon and periodically check for a
   changed IP-adresse and reconnect to the endpoint when the IP address
   change.

DEFAULT SSH OPTIONS
    ssh is started with "-N -C -n -q" by default.

REQUIREMENTS
   ssh, hostname, netstat

AUTHOR
    Written by Jan Henning Thorsen - jhthorsen -at- cpan.org
MAN
}

if [ -z "$1" ]; then
    man;
    exit 1;
fi

# -N = Do not execute a remote command
# -C = compression
# -n = prevents reading from stdin
# -q = quiet
SSH_COMMAND="ssh -N -C -n -q $@";
SSH_PID=$$; # kill_ssh() will skip killing this pid
IFCONFIG_CACHE="";

# kill child when this script ends
trap '{ kill -15 $SSH_PID; }' 2 3 15; # INT QUIT TERM

start_ssh () {
    $SSH_COMMAND &
    SSH_PID=$!;
    kill_ssh 0 && return 0;
    echo "Failed to start ssh process";
    return 1;
}

kill_ssh () {
    [ $SSH_PID -eq $$ ] && return 1;
    kill -$1 $SSH_PID 2>/dev/null 1>/dev/null;
    return $?;
}

ip_address_has_changed () {
    NETSTAT=$(netstat -n --program --tcp 2>/dev/null | grep "$SSH_PID");

    for IP in $(hostname --all-ip-addresses); do
        echo $NETSTAT | grep $IP 1>/dev/null && return 1;
    done

    return 0;
}

while sleep 1; do
    ip_address_has_changed && kill_ssh 15;
    kill_ssh 0 || start_ssh;
done

exit 0;
