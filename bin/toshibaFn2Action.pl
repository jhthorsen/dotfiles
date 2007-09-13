#!/usr/bin/perl

#================
# fn2action v0.1
#================

use strict;
use warnings;
use IO::File;
use Time::HiRes qw/usleep/;


my @SUDO            = qw/sudo -b -H -u eidolon/;
my $KEYS_FILE       = "/proc/acpi/toshiba/keys";
my $VERBOSE         = 1;
my %CODE            = (
    '322'    => main->can("bluetooth"),              # F8  bluetooth
    '321'    => 0xae,                                # F7  bright up
    '0x0141' => "/etc/acpi/toshbright.sh up",        # F7  bright up
    '320'    => 0xad,                                # F6  bright down
    '0x0140' => "/etc/acpi/toshbright.sh down",      # F6  bright down
    '445'    => main->can("suspend"),                # F4  sleep
    '0x013b' => "gnome-screensaver-command --lock",  # F1  screensaver
    '257'    => 0xaa,                                # ESC mute
    '258'    => 0xab,                                # 1   vol down
    '259'    => 0xac,                                # 2   vol up
    '0x0114' => 0xb0,                                # t   terminal
    '0x012e' => "qalculate-gtk",                     # c   calculator
    '274'    => 0xb2,                                # e   email
    '291'    => 0xb3,                                # h   home
    '0x011f' => "beagle-search",                     # s   search
    '0x0111' => "firefox",                           # w   www
    '0x012d' => "xchat",                             # x   xchat
);
my $ACPI_FAKEKEY    = "/usr/bin/acpi_fakekey";
my $ZENITY          = "/usr/bin/zenity";
my $CODES_PR_SECOND = 20;
my $keys            = IO::File->new();
my $content;

$keys->open($KEYS_FILE, "r+");
IO::File->input_record_separator(undef);
$|++;


FLUSH_FILE:
while(1) {
    readkey($keys) or last;
}


PROGRAM_LOOP:
while(1) {

    ### init
    usleep 1e6 * 1 / $CODES_PR_SECOND;
    my $hex_code = readkey($keys) or next;
    my $int_code = hex $hex_code;
    my $command  = $CODE{$hex_code} || '';
    my @cmd      = split /\s+/, $command;

    ### fix command
    $command = (@cmd and -e $cmd[0]) ? $command : "@SUDO $command &";

    ### debugging
    if($VERBOSE) {
        printf "Input: %6s %-4s Code: %-8s Program: %s\n",
            $hex_code,
            $int_code,
            (ref $CODE{$int_code} ? 'internal' : $CODE{$int_code} || '-'),
            ($CODE{$hex_code} || '-'),
            ;
    }

    ### execute action
    if($CODE{$hex_code}) {
        system "$command";
    }

    ### run method
    if(ref(my $code = $CODE{$int_code})) {
        $code->();
    }

    ### send fake key
    elsif($CODE{$int_code}) {
        system $ACPI_FAKEKEY => $CODE{$int_code};
    }
}


### the end
$keys->close;
exit 0;


sub readkey { #===============================================================

    ### init
    my $keys = shift;
    $keys->seek(0, 0);
    $keys->read($content, 1024);

    ### get data
    my($new, $hex_code) = ($content =~ / (\d) \D+ (\w+) /x) or return;

    ### the end
    $keys->print("hotkey_ready:0") if($new);
    return $new ? $hex_code : undef;
}

sub suspend { #===============================================================

    ### init
    my @question = (
                       "--question",
                       "--title", "Alert",
                       "--text",  "Do you want to suspend the computer?",
                   );

    ### ask to suspend
    unless(system $ZENITY => @question) {
        system "/etc/acpi/sleep.sh",
    }
}

sub bluetooth { #=============================================================

    ### init
    my $status  = qx"/usr/bin/toshset -bluetooth";
    my $TOSHSET = "/usr/bin/toshset";
    my @NOTIFY  = qw(/usr/bin/notify-send -t 2000 -i gtk-dialog-info);

    print $status if($VERBOSE);

    ### turn on
    if($status =~ /off/) {
        #system $TOSHSET => "-bluetooth", "on"
        print "@SUDO => @NOTIFY Bluetooth is turned off";
    }
    else {
        #system $TOSHSET => "-bluetooth", "off"
        print "@SUDO => @NOTIFY Bluetooth is turned off";
    }
}

