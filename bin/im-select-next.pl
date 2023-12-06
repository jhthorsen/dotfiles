#!/usr/bin/env perl
use strict;
use warnings;

my @lang = qw(
  com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese.Katakana
  com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese
  org.unknown.keylayout.ABCProgramming
);

my $curr = qx{/opt/homebrew/bin/im-select};
my $next;
for my $i (0..(@lang - 1)) {
  ($next = $lang[$i + 1]) && last if index($curr, $lang[$i]) == 0;
}

$next ||= $lang[0];
system '/usr/bin/osascript', -e => qq(display notification "$next" with title "im-select-next");
system '/opt/homebrew/bin/im-select', $next;
