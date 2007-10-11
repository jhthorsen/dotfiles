#!/usr/bin/perl

use strict;
use warnings;


### init
my $batt_info = "/proc/acpi/battery/BAT0/info";
my $batt_stat = "/proc/acpi/battery/BAT0/state";
my %stat      = (read_proc($batt_info), read_proc($batt_stat));

### print state
printf "%-20s: %s\n",
       "State",
       ucfirst($stat{'charging_state'}),
       ;

### print rate
printf "%-20s: %5.2f W\n",
       "Rate",
       $stat{'present_rate'} / 1e3,
       ;

### print remaining
printf "%-20s: %5.2f Wh\n",
       "Remaining capasity",
       $stat{'remaining_capacity'} / 1e3,
       ;

### print rate
if($stat{'present_rate'} > 0) {
    my $time_left = $stat{'remaining_capacity'} / $stat{'present_rate'};
    printf "%-20s: %ih %im (%0.1f%%)\n",
           "Time left",
           $time_left,
           ($time_left - int($time_left)) * 60,
           $stat{'remaining_capacity'} / $stat{'last_full_capacity'} * 100,
           ;
}
else {
    printf "%-20s: %s\n",
           "Time left",
           "Infinite",
           ;
}

### the end
exit 0;


sub read_proc { #=============================================================

    ### init
    my $file = shift || "";
    my %info;

    open(my $fh, "<", $file) or die "Coult not open $file\n";
    %info = map {
                    my($k, $v) = /([^:]+):\s*(\w+)/;
                    $k         =~ s/\s/_/g;
                    $k         => $v;
                } (@_ = <$fh>);
    close $fh;

    ### the end
    return %info;
}

#=============================================================================
__END__
