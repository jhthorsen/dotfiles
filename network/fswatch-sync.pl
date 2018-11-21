#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::File 'path';

my $remote_host = shift;
my $remote_path = shift;
my $pwd         = path->to_abs->to_string;
my $pwd_re      = quotemeta $pwd;

_usage() unless $remote_host and $remote_path;

$remote_path =~ s!/+$!!;
print "# Syncing $pwd => $remote_host:";
_usage() unless 0 == system ssh => $remote_host => "ls -d $remote_path";

my @fswatch = ('fswatch');
push @fswatch, '--event-flag-separator=:';
push @fswatch, '-x';
push @fswatch, $pwd;

while (1) {
  open my $FSWATCH, '-|', @fswatch or die "@fswatch: $!";

  while (<$FSWATCH>) {
    chomp;
    my $op = s/\s+(\S+)$// ? $1 : "Unknown";
    my $file = $_;
    print "# $op $file\n";
    next if $op !~ /IsFile/;
    next if $op =~ /Created.*Removed/ or $op =~ /Removed.*Renamed/;
    s/^$pwd_re// or die "INVALID_FILE_NAME: $file ($pwd_re)";
    my $rel = $_;
    my @cmd
      = $op =~ /Removed/
      ? (ssh => -C => $remote_host, "rm $remote_path$rel")
      : (scp => -C => $file => "$remote_host:$remote_path$rel");
    print "> @cmd\n";
    system @cmd;
  }

  warn "\n! @fswatch: $?\n\n" if $?;
}

sub _usage {
  die "Usage: $0 ssh.example.com /sync/to/directory\n";
}
