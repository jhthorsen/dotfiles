#!/usr/bin/perl

=head1 NAME

toshiba-fn2action.pl - Reads Fn+X keypress and run execute actions

=head1 SYNOPSIS

 toshiba-fn2action.pl;

The sourcecode should be read and configured to user preferences.

=cut

use strict;
use warnings;
use IO::File;
use Time::HiRes qw/usleep/;

my $USER = 'someusername';
my @SUDO = (sudo => '-b', '-H', '-u', $USER);
my $TOSHSET = "/usr/bin/toshset";
my $KEYS_FILE = "/proc/acpi/toshiba/keys";
my $VERBOSE = $ENV{'VERBOSE'} ? $ENV{'VERBOSE'} : 0;
my %CODE = (
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
my $ACPI_FAKEKEY = "/usr/bin/acpi_fakekey";
my $ZENITY = "/usr/bin/zenity";
my $CODES_PR_SECOND = 20;

$|++;
exit main();

=head2 FUNCTIONS

=head2 main

This is the main program loop. Will read keys and execute actions.

=cut

sub main {
    my $keys = IO::File->new;

    $keys->open($KEYS_FILE, "r+") or die $!;
    $keys->input_record_separator(undef);

    # flush file
    while(1) {
        readkey($keys) or last;
    }

    while(1) {
        usleep 1e6 * 1 / $CODES_PR_SECOND;

        my $hex_code = readkey($keys) or next;
        my $int_code = hex $hex_code;
        my $command = $CODE{$hex_code} || '';
        my @cmd = split /\s+/, $command;

        $command = (@cmd and -e $cmd[0]) ? $command : "@SUDO $command &";

        debug("Input: %6s %-4s Code: %-8s Program: %s",
            $hex_code,
            $int_code,
            (ref $CODE{$int_code} ? 'internal' : $CODE{$int_code} || '-'),
            ($CODE{$hex_code} || '-'),
        );

        if($CODE{$hex_code}) {
            system "$command";
        }
        elsif(ref(my $code = $CODE{$int_code})) {
            $code->();
        }
        elsif($CODE{$int_code}) {
            system $ACPI_FAKEKEY => $CODE{$int_code};
        }
    }

    $keys->close;

    return 0;
}

=head2 readkey

 $hex_code = readkey($fh_obj);

Returns a C<$hex_code> if a new key has arrived or empty on failure.

=cut

sub readkey {
    my $keys = shift;

    $keys->seek(0, 0);
    $keys->read(my $content, 1024);

    my($new, $hex_code) = ($content =~ / (\d) \D+ (\w+) /x);

    if($new) {
        $keys->print("hotkey_ready:0");
        return $hex_code;
    }

    return;
}

=head2 suspend

 suspend();

Will use C<zenity> to ask the user to suspend or not.

=cut

sub suspend {
    my @question = (
                       "--question",
                       "--title", "Alert",
                       "--text",  "Do you want to suspend the computer?",
                   );

    if(system($ZENITY => @question) == 0) {
        system "/etc/acpi/sleep.sh",
    }
}

=head2 bluetooth

 bluetooth();

Will toggle bluetooth radion on/off, and notify the user.

=cut

sub bluetooth {
    my $status = qx"/usr/bin/toshset -bluetooth";
    my @NOTIFY = qw(/usr/bin/notify-send -t 2000 -i gtk-dialog-info);

    debug($status);

    if($status =~ /off/) {
        system $TOSHSET => "-bluetooth", "on";
        system @SUDO, @NOTIFY, "Bluetooth is turned on";
    }
    else {
        system $TOSHSET => "-bluetooth", "off";
        system @SUDO, @NOTIFY, "Bluetooth is turned off";
    }
}

=head2 debug

 debug($format, @args);

Print a message to STDERR, if C<$VERBOSE> is set.

=cut

sub debug {
    printf STDERR @_ if $VERBOSE;
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
