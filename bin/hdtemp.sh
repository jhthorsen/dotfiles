#!/bin/bash

# Example output: /dev/sdb: 34 C

for i in /dev/hd? /dev/sd?; do
    T=`smartctl -a $i | grep "^194" | awk '{print $10}'`;
    if [ "x$T" != "x" ]; then
        echo "$i: $T C";
    fi
done

exit 0;
