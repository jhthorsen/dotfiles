#!/usr/bin/perl

#====================
# find_pid_by_name.pl
#====================

use strict;
use warnings;

my $search = shift @ARGV || die "No program to search for\n";
my %switch = @ARGV % 2 ? (@ARGV,1) : (@ARGV);
my $i      = 0;
my @pid    = _find_pid_by_name($search);


unless($switch{'-v'} or $switch{'--verbose'}) {
    print "$_\n" for(@pid);
}

die "Could not find matching program: $search\n" unless(@pid);

exit 0;


sub _find_pid_by_name { #=====================================================

    ### init
    my $name = pop or return;
    my @pid;

    ### get pids
    opendir(PROC, "/proc");

    PROC_DIR:
    for my $pid (readdir PROC) {
        open(STATUS, "<", "/proc/$pid/status") or next;

        PROC_STATUS:
        while(<STATUS>) {
            if(s/Name:\s+//i and /$name/) {
                if($switch{'-v'} or $switch{'--verbose'}) {
                    printf "%6i | %s", $pid, $_;
                }
                push @pid, $pid;
                next PROC_DIR;
            }
        }
        close STATUS;
    }
    closedir PROC;

    @pid = sort @pid;

    ### the end
    return wantarray ? @pid : \@pid;
}
