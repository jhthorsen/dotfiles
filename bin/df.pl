#!/usr/bin/env perl
use strict;
use warnings;

open my $DF, '-|', qw(df -h);
my (@total, @len);
while (my $line = readline $DF) {
  chomp $line;
  if ($. > 1) {
    my $i = 0;
    for my $col ($line =~ /(\s*\S+)/g) {
      my $val = ($total[$i] and $total[$i] =~ /^(\d+)$/) ? $1 : 0;
      $total[$i] = $col =~ /\b(\d+\.?\d*)([GKMT])/ ? $val + size($1, $2) : $val;
      $len[$i] ||= length $col;
      $i++;
    }
  }
  print "$line\n";
}

shift @total;
printf join("", map {"\%${_}s"} @len) . "\n", 'Total', map { human($_) } @total;

sub size {
  return $_[0] * 1e3  if $_[1] eq 'K';
  return $_[0] * 1e6  if $_[1] eq 'M';
  return $_[0] * 1e9  if $_[1] eq 'G';
  return $_[0] * 1e12 if $_[1] eq 'T';
  return $_[0];
}

sub human {
  return "" unless $_[0];
  return +(int($_[0] / 1e3 * 10) / 10) . "k" if $_[0] < 100e3;
  return +(int($_[0] / 1e6 * 10) / 10) . "M" if $_[0] < 100e6;
  return +(int($_[0] / 1e9 * 10) / 10) . "G" if $_[0] < 100e9;
  return +(int($_[0] / 1e12 * 10) / 10) . "T";
}
