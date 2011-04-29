#!/bin/sh

sudo fdisk -s /dev/sd* \
    | perl -nle'/(\w+):\s(\d+)/ and printf "%5s: %8.2f GB\n", $1, $2/1e6' \
    ;

exit $?
