#!/bin/sh

man() {
    cat <<'MAN'
NAME
    Socks daemon - Keep connected with Socks/SSH

SYNOPSIS
    $ socks-daemon.sh;
    $ socks-daemon.sh <host> <port>

DESCRIPTION
   This script will start SSH as a SOCKS daemon and will periodically
   check for a changed IP-adresse and reconnect to the endpoint so you
   don't have to.

REQUIREMENTS
   ssh, sort, perl

AUTHOR
    Written by Jan Henning Thorsen - jhthorsen -at- cpan.org
MAN
}

if [ -z $2 ]; then
    man;
    exit 1;
fi

HOST=$1;
PORT=$2;
SOCKS_COMMAND="ssh -N -C -D $PORT $HOST";
SOCKS_PID=0;
IFCONFIG_CACHE="";

# kill child when this script ends
trap "{ kill $SOCKS_PID; }" 2 3 15; # INT QUIT TERM

start_socks () {
    if is_socks_running; then
        stop_socks;
    fi

    $SOCKS_COMMAND &
    SOCKS_PID=$!;
    
    if kill -0 $SOCKS_PID; then
        echo "Started socks daemon";
        return 0;
    else
        echo "Failed to start socks daemon";
        return 1;
    fi
}

stop_socks () {
    if kill $SOCKS_PID; then
        echo "Stopped socks daemon";
        return 0;
    else
        echo "Failed to stop socks daemon";
        return 1;
    fi
}

is_socks_running () {
    if [ $SOCKS_PID -gt 0 ]; then
        kill -0 $SOCKS_PID 2>/dev/null 1>/dev/null
        return $?;
    else
        return 1;
    fi
}

new_ip_address () {
    IFCONFIG_OUTPUT=$(
        ifconfig \
        | sort \
        | perl -ne'/addr:/ and chomp and $o.=$_}{print $o' \
    );

    if [ "x$IFCONFIG_OUTPUT" = "x$IFCONFIG_CACHE" ]; then
        return 1;
    else
        echo "IP address is changed";
        IFCONFIG_CACHE=$IFCONFIG_OUTPUT;
        return 0;
    fi
}

while sleep 2; do
    if new_ip_address; then
        if is_socks_running; then
            stop_socks;
        fi
        start_socks;
    fi
    if ! is_socks_running; then
        start_socks;
    fi
done

exit 0;
