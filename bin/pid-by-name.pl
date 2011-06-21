#!/usr/bin/perl

=head1 NAME

pid-by-name.pl - Print PID by program name

=head1 SYNOPSIS

 pid-by-name.pl <program name>;

C<pid-by-name.pl> might output more than one pid.

=cut

use strict;
use warnings;

my $search = shift @ARGV || die "No program to search for\n";
my %switch = @ARGV % 2 ? (@ARGV, 1) : (@ARGV);

print "$_\n" for(find_pid_by_name($search));

exit 0;

=head1 FUNCTIONS

=head2 find_pid_by_name

 @pids = find_pid_by_name($name);

Will search through C</proc/> for "program name", and add its pid to C<@pids>.

=cut

sub find_pid_by_name {
    my $name = shift or return;
    my @pid;

    opendir my $PROC, "/proc";

    FILE:
    for my $pid (readdir $PROC) {
        $pid =~ /^\d+$/ or next FILE;
        open my $STATUS, "<", "/proc/$pid/status" or next FILE;

        STATUS:
        while(<$STATUS>) {
            if(/Name:.*?$name/) {
                push @pid, $pid;
                next FILE;
            }
        }
    }

    return sort @pid;
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
