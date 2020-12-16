# Netgear RAX120

This directory contains some helper scripts that work on Netgear RAX120,
firmware version V1.0.1.122.

It looks like Netgear decided to disable telnet on later firmware versions.

TODO: Figure out if I can upgrade the firmware, after "cust_enable_telnet.sh"
is in place.

## Crontab entries

    # remove
    08 01 * * * /usr/share/armor/bdupd_start_schedule.sh

    # add
    */5 * * * * /usr/sbin/cust_canhazip.sh
    */5 * * * * /usr/sbin/cust_services.sh 1>/dev/null 2>/dev/null
    */5 * * * * /usr/sbin/cust_stats.sh

## Extract information

    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_canhazip.txt
    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_enable_telnet.txt
    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_hosts_status.txt
    curl http://admin:LOGINPASSWORD@192.168.1.1/cust_stats.txt

## Useful resources

    # Enable telnet on V1.0.1.122
    http://192.168.1.1/debug.htm

## Bitdefender

    $ config show | grep -i armor
    armor_jump=63335619
    armor_login_mark=1
    dgc_func_have_armor=1
    lastRebootReason_armor=1
    armor_note=1

    /bin/config set dgc_func_have_armor=0
    /bin/config set armor_note=1
    /bin/config set lastRebootReason_armor=0
    /bin/config set armor_login_mark=0
    /bin/config set dgc_func_have_armor=0

    /opt/bitdefender/bin/bd_procd stop

    mv /etc/rc.d/*armor* etc/backup.rc.d/
    ps | grep -v "\[" | grep bit
    ps | grep -v "\[" | grep bit | cut -d' ' -f1 | xargs kill

    10001 root      4344 S    /opt/bitdefender/bin/bdcrashd -start -no-detach
    10016 root      4956 S    /opt/bitdefender/bin/bdsetter -start -no-detach -sav
    10023 root      6024 S    /opt/bitdefender/bin/bdexchanged -start -no-detach
    10131 root     15820 S    /opt/bitdefender/bin/bdcloudd -start -no-detach
    10138 root      5392 S    /opt/bitdefender/bin/bdboxsettings -start -no-detach
    10149 root      5460 S    /opt/bitdefender/bin/bddevicediscovery -start -no-de
    10160 root      5352 S    /opt/bitdefender/bin/bdbrokerd -start -no-detach
    10179 root      5236 S    /opt/bitdefender/bin/bdvad -start -no-detach
    10186 root      4676 S    /opt/bitdefender/bin/bdgusterupdd -start -no-detach
    10195 root      6188 S    /opt/bitdefender/bin/bdgusterd -start -no-detach
    10208 root      4356 S    /opt/bitdefender/bin/bdheartbeatd -start -no-detach
    10906 root      9532 S    /opt/bitdefender/bin/bdpush -c /opt/bitdefender/var/
    11413 root      5452 S    /opt/bitdefender/bin/bdavahi -scan -interfaces=br0
    11414 root      5964 S    /opt/bitdefender/bin/bdupnp -scan -ifname=br0
    11415 root      4844 S    /opt/bitdefender/bin/bdleases
    14744 root     13004 S    /opt/bitdefender/guster/gusterupd -r /opt/bitdefende
    14751 root     95548 S    /tmp/mnt/bitdefender/guster/guster -c guster.yaml -c
