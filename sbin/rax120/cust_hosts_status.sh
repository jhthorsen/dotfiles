#!/bin/sh

cat /proc/net/arp | while read l; do
  IP=$(echo $l | awk '{print $1}');
  echo $IP | grep -q "\." || continue;

  MAC=$(echo $l | awk '{print $4}');
  NAME=$(config show | grep -i "access_control.*$MAC" | tail -n1 | awk '{print $5}');
  STATUS=$(ping -c1 -w1 $IP &>/dev/null && echo "true " || echo "false");

  echo "up:$STATUS mac:$MAC ip:$IP name:$NAME" >> /tmp/cust_hosts_status.txt;
done

config show | grep access_control >> /tmp/cust_hosts_status.txt;

mv /tmp/cust_hosts_status.txt /www/cust_hosts_status.txt
