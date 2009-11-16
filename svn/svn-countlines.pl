#!/usr/bin/perl

=head1 NAME

svn-countlines.pl

=head1 SYNOPSIS

 $ svn_countlines.pl <options>

=head2 OPTIONS

=over 4

=item --revision|-r

Required: --revision r1:r2

=item --offset|-o

Default: 0

Should point to the previous revisions counted lines.

=item --dir|-d

Default: $PWD

=item --debug

Print removed/added lines to STDERR.

=back

=cut

use strict;
use warnings;
use Getopt::Long;

my %arg = (
    dir    => q(.),
    offset => 0,
);

GetOptions(\%arg, qw/ revision|r=s dir|d=s offset|o=i debug /);
Getopt::Long::HelpMessage() unless($arg{'revision'});

my($r1, $r2) = split /:/, $arg{'revision'};
my $svn_bin  = $ENV{'SVN'} || q(/usr/bin/svn);
my %lines    = ("-" => 0, "+" => $arg{'offset'});

die "$svn_bin is not executeable\n" unless(-x $svn_bin);

for my $rev ($r1..$r2) {
    my $next = $rev + 1;
    my($DIFF, $VERSION);

    open($VERSION, "-|", $svn_bin => info => "-r$rev" => $arg{'dir'});
    while(readline $VERSION) {
        /Last\sChanged\sDate:\s([^(]+)/ and print "$rev - $1- ";
    }

    open($DIFF, "-|", $svn_bin => diff => "-r$rev:$next" => $arg{'dir'});
    while(readline $DIFF) {
        /^[+-]{3}/ and next;
        /^([+-])/  or  next;
        $lines{$1}++;
    }

    print +($lines{'+'} - $lines{'-'}), "\n";

    if($arg{'debug'}) {
        warn "Removed: $lines{'-'}\n";
        warn "Added: $lines{'+'}\n";
    }
}

exit;

=head1 AUTHOR

Jan Henning Thorsen - http://flodhest.net/about

=cut
