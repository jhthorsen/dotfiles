#!/bin/sh

# sudo apt-get install libshairport1 shairplay libshairplay0

PATH=/usr/bin:$PATH;
LOG_FILE=/dev/null;
PID_FILE=/tmp/shairplay-$USER.pid;

if [ -r $PID_FILE ]; then
  if kill -0 $(cat $PID_FILE) 2>/dev/null; then
    echo "$0 is running.";
    exit 0;
  fi
fi

echo $$ > $PID_FILE;

echo "Starting shairplay...";
DISPLAY=:0 shairplay -a home 2>$LOG_FILE 1>$LOG_FILE;
