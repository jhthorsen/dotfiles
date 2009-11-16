#!/bin/sh

RULE=$1;
DUMP=$2;
INTERFACE=$3;
TIMEOUT=$4;

# set default values
[ -z $INTERFACE ] && INTERFACE="eth0";
[ -z $DUMP      ] && DUMP=`date '+dump_%s'`;
[ -z $TIMEOUT   ] && TIMEOUT=1200;

# print usage
if [ $RULE == '-h' ]; then
    echo "Usage: $0 <rule> <dump_file> <interface> <timeout>";
    exit 0;
fi

# start tcpdump
echo "$ tcpdump -i $INTERFACE -s 1500 -w $DUMP $RULE";
tcpdump -i $INTERFACE -s 1500 -w $DUMP $RULE &
TCPDUMP_PID=$!;

# kill tcpdump, when this script exit
trap "{ kill $TCPDUMP_PID; }" SIGINT SIGTERM;

# exit if tcpdump did not start
kill -0 $TCPDUMP_PID;
if [ $? -ne 0 ]; then
    echo "tcpdump did not start";
    exit 255;
fi


timer=0;

# echo the size of $DUMP
while sleep 1; do
    fileinfo=`du $DUMP`;
    echo -ne "$fileinfo\r";
    (( timer++ ));
    [ $timer -ge $TIMEOUT ] && exit 1;
done

exit 0;
