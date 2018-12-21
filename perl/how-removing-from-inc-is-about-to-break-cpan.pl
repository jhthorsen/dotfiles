#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;

my %u;

opendir(my $DP, '.') or die $!;
while (my $p = readdir $DP) {
  opendir(my $TH, "$p/t") or next;

  FILE:
  while (my $t = readdir $TH) {
    open my $FH, '<', "$p/t/$t" or next;
    my @f;
    while (<$FH>) {
      push @f, qq(use lib '.';\n) if /use t::/ and !$u{$p}{$t}++;
      push @f, $_;
    }
    if ($u{$p}{$t}) {
      close $FH;
      open my $FH, '>', "$p/t/$t" or die $!;
      print $FH join '', @f;
    }
  }

  if ($u{$p}) {
    chdir $p;
    system "git commit t -m'http://blogs.perl.org/users/todd_rinaldo/2016/11/how-removing-from-inc-is-about-to-break-cpan.html'";
    chdir "..";
  }
}

for my $p (sort keys %u) {
  print "$p\n";
}
