#!/usr/bin/perl

=head1 NAME

battery.pl - Print battery status

=head1 DESCRIPTION

Will print information about your battery to STDOUT.

=head1 SYNOPSIS

 battery.pl;
 battery.pl /proc/acpi/battery/BAT0;

=cut

use strict;
use warnings;

my $base = shift || '/proc/acpi/battery/BAT0';
my $batt_info = "$base/info";
my $batt_stat = "$base/state";
my %info = (read_proc($batt_info), read_proc($batt_stat));
my @format = (
    [ charging_state => 'Battery state' => '%s' ],
    [ present_rate => 'Discharge rate' => '%5i mW' ],
    [ remaining_capacity => 'Remaining power' => '%5i mWh' ],
    [ time_left => 'Remaining time' => '%5.2f h' ],
    [ percent_left => 'Remaining percentage' => '%5.2f %%' ],
);

for my $f (@format) {
    printf "%-22s $f->[2]\n", $f->[1], $info{$f->[0]};
}

exit 0;

=head1 FUNCTIONS

=head2 read_proc

 %info = read_proc($file);

Returns information from a /proc file.

=cut

sub read_proc {
    my $file = shift or return
    my %info;

    open(my $FH, "<", $file) or die "Coult not open $file\n";

    LINE:
    while(<$FH>) {
        chomp;
        my($key, $value) = /(\w[^:]+):\s*(\w+)/ or next;
        $key =~ s/\s/_/g;
        $info{$key} = $value;
    }

    if(defined $info{'present_rate'}) {
        if($info{'present_rate'} > 0) {
            $info{'time_left'}
                = $info{'remaining_capacity'} / $info{'present_rate'};
            $info{'percent_left'}
                = $info{'remaining_capacity'} / $info{'last_full_capacity'} * 100;
        }
        else {
            $info{'time_left'} = -1;
            $info{'percent_left'} = -1;
        }
    }

    return %info;
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
