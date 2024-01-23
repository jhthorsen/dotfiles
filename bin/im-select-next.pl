#!/usr/bin/env perl
use strict;
use warnings;

my ($curr, $next) = (current_layout());
my @lang = qw(
  com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese.Katakana
  com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese
  org.unknown.keylayout.ABCProgramming
);

@lang = grep { index("@ARGV", $_) >= 0 } @lang if @ARGV;

for my $i (0..(@lang - 1)) {
  ($next = $lang[$i + 1]) && last if index($curr, $lang[$i]) == 0;
}
$next ||= $lang[0];

die "Usage: $0 [name]\n" unless $next;
print STDERR qq(Changing from "$curr" to "$next"\n) if -t STDERR;
exit 0 if $next eq $curr;
system '/usr/bin/osascript', -e => qq(display notification "$next" with title "im-select-next");
system '/opt/homebrew/bin/im-select' => $next;

sub current_layout {
  system 'brew install im-select' unless my $im_select = which('im-select');
  die 'Unable to install im-select' unless $im_select ||= which('im-select');
  my $curr = qx{$im_select};
  chomp $curr;
  return $curr;
}

sub which {
  my $name = shift;
  my @path = grep { -x "$_/$name" } (split(/:/, $ENV{PATH}), '/opt/homebrew/bin');
  return @path ? "$path[0]/$name" : undef;
}
