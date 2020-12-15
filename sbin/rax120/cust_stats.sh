#!/bin/sh

# uci show
# show_usb_sata_info
# show_all_button_status
# /lib/functions.sh
# cat /proc/net/dev
# cat /proc/net/wireless

config show | grep telnet >> /tmp/cust_stats.txt;
echo "firmware=$(grep DISTRIB_REVISION /etc/openwrt_release | cut -d= -f2 | sed "s/'//g")" >> /tmp/cust_stats.txt;
echo "loadavg=$(cat /proc/loadavg)" >> /tmp/cust_stats.txt;
echo "telnet=$(cat /tmp/enable_telnet)" >> /tmp/cust_stats.txt;
echo "telnetenable=$(pidof telnetenable 2>/dev/null)" >> /tmp/cust_stats.txt
echo "uname=$(uname -a)" >> /tmp/cust_stats.txt;
echo "uptime=$(cat /proc/uptime)" >> /tmp/cust_stats.txt;
echo "utelnetd=$(pidof utelnetd 2>/dev/null)" >> /tmp/cust_stats.txt
echo "version=$(cat /proc/version)" >> /tmp/cust_stats.txt;

mv /tmp/cust_stats.txt /www/cust_stats.txt;
