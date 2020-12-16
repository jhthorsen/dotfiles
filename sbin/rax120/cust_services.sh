#!/bin/sh
echo -n 1 > /home/enable_telnet;
/usr/sbin/utelnetd -d -i br0;

/bin/config set armor_login_mark=0
/bin/config set armor_note=1
/bin/config set dgc_func_have_armor=0
/bin/config set dgc_func_have_armor=0
/bin/config set lastRebootReason_armor=0
/opt/bitdefender/bin/bd_procd stop

[ -d /etc/backup.rc.d ] || mkdir /etc/backup.rc.d;
mv /etc/rc.d/*armor* /etc/backup.rc.d/
