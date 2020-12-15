# Netgear RAX120

This directory contains some helper scripts that work on Netgear RAX120,
firmware version V1.0.1.122.

It looks like Netgear decided to disable telnet on later firmware versions.

TODO: Figure out if I can upgrade the firmware, after "cust_enable_telnet.sh"
is in place.

## Crontab entries

    */1 * * * * /usr/sbin/cust_enable_telnet.sh
    */5 * * * * /usr/sbin/cust_canhazip.sh
    */5 * * * * /usr/sbin/cust_enable_telnet.sh
    */5 * * * * /usr/sbin/cust_stats.sh

## Extract information

    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_canhazip.txt
    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_enable_telnet.txt
    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_hosts_status.txt
    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_stats.txt

## Useful resources

    # Enable telnet on V1.0.1.122
    http://192.168.1.1/debug.htm
