#!/usr/bin/perl

#=====================================
# wifi_daemon
# Created by jhthorsen jhth@online.no
#=====================================

use strict;

#== USER SETTINGS ================
my $IWLIST   = '/sbin/iwlist';
my $IWCONFIG = '/sbin/iwconfig';
my $IFUP     = '/sbin/ifup';
my $IFDOWN   = '/sbin/ifdown';
my $KILLALL  = '/usr/bin/killall';
my $DEV      = 'eth1';
my %KEY      = (
    essid1 => 's:asciikey',
);
#=================================

my $current = '';
my %regex   = (
    ESSID   => qr/ESSID:"(\w+)"/,
    KEY     => qr/key:(\w+)/,
    QUALITY => qr/Quality=(\w+)/,
    END     => qr/Extra:\s(\w+)/,
);

while(1) { #==================================================================

    ### init
    my @iwscan = qx"$IWLIST $DEV scanning 2>/dev/null";
    my(%param, %wlan);

    ### fix params
    while(my $l = shift @iwscan) {
        if($l =~ /$regex{'ESSID'}/) {
            $param{'essid'} = $1
        }
        elsif($l =~ /$regex{'KEY'}/) {
            $param{'key'} = $1;
        }
        elsif($l =~ /$regex{'QUALITY'}/) {
            $param{'quality'} = $1;
        }
        elsif($l =~ /$regex{'END'}/) {
            if($param{'key'} eq 'on') {
                $param{'key'} = $KEY{$param{'essid'}};
            }
            if($param{'key'}) {
                my $q = $param{'quality'};
                $q++ unless(length $param{'key'} > 3);
                $wlan{$q} = { %param };
            }
        }
    }

    ### setup wlan
    if(keys %wlan) {
        my $new = (sort keys %wlan)[-1];
        %param  = %{$wlan{$new}};
        if($param{'essid'} and $param{'essid'} ne $current) {
            $current = $param{'essid'};
            system "$IFDOWN $DEV";
            system "$IWCONFIG $DEV essid $param{'essid'} key $param{'key'}";
            system "$IFUP $DEV";
        }
    }

    ### sleep
    sleep 5;
}

### the end
exit 0;

