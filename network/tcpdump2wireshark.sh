#!/bin/bash

RULE=$1;
DUMP=$2;
INTERFACE=$3;
TIMEOUT=$4;

[ -z $INTERFACE ] && INTERFACE="eth0";
[ -z $DUMP      ] && DUMP=`date '+dump_%s'`;
[ -z $TIMEOUT   ] && TIMEOUT=1200;


### START TCPDUMP
echo "$ tcpdump -i $INTERFACE -s 1500 -w $DUMP $RULE";
tcpdump -i $INTERFACE -s 1500 -w $DUMP $RULE &
TCPDUMP_PID=$!;

### KILL TCPDUMP ON EXIT
trap "{ kill $TCPDUMP_PID; }" SIGINT SIGTERM;

### IS TCPDUMP STARTED?
kill -0 $TCPDUMP_PID;
if [ $? -ne 0 ]; then
    echo "...is not running";
    exit 255;
fi


timer=0;
while sleep 1; do
    fileinfo=`du $DUMP`;
    echo -ne "$fileinfo\r";
    (( timer++ ));
    [ $timer -ge $TIMEOUT ] && exit 1;
done


### THE END
exit 0;

