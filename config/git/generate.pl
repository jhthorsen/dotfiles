#!/usr/bin/env perl
use strict;
use warnings;
use experimental qw(signatures);
use Cwd qw(abs_path);
use File::Basename qw(dirname);

my $config_template = sprintf '%s/config', dirname(Cwd::abs_path($0));
my $config_file     = "$ENV{HOME}/.gitconfig";
exit 0 if config_up_to_date($config_template, $config_file);

my $config = config_read(fh($config_template));

my %has;
$has{signingkey} = length(qx"gpg --armor --export $config->{user}{signingkey}");
warn sprintf "# Has %s\n", join ', ', map {"$_=$has{$_}"} sort keys %has unless $ENV{QUIET};

warn "# Writing $config_file\n" unless $ENV{QUIET};
config_write(\%has, fh($config_template, "<"), fh($config_file, ">"));
exit 0;

sub config_write ($has, $SRC, $DEST) {
  my ($section, %config) = ('');
  print {$DEST} "# Generated from $config_template\n";

  while (<$SRC>) {
    $section = $1 if /^\[([^\]]+)\]/;
    next          if !$has->{signingkey} and ($section eq 'gpg' or /\b(gpgsign|signingkey)\b/);
    print {$DEST} $_;
  }
}

sub config_read ($fh) {
  my ($section, %config) = ('');
  while (<$fh>) {
    $section              = $1       if /^\[([^\]]+)\]/;
    $config{$section}{$1} = trim($2) if $section and /(\S+)\s*=\s*(.*)/;
  }

  return \%config;
}

sub config_up_to_date ($src, $dest) {
  my @stat = map { (stat $_)[9] // 0 } $src, $dest;
  system qw(diff -u), $dest, $src if !$ENV{QUIET} and $stat[0] and $stat[1];
  return $stat[0] < $stat[1];
}

sub fh ($file, $mode = '<') {
  open my $FH, $mode, $file or die "open $mode $file: $!";
  return $FH;
}

sub trim ($str) {
  $str =~ s!\s+$!!;
  $str =~ s!^\s+!!;
  return $str;
}
