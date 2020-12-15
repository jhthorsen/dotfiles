#!/bin/sh
echo -n 1 > /home/enable_telnet;
/usr/sbin/utelnetd -d -i br0;
