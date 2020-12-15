#!/bin/sh
ip addr show dev brwan | grep inet | sed 's/^\s*//' | awk '{print $2}' > /www/cust_canhazip.txt
