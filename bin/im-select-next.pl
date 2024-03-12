#!/usr/bin/env perl
use strict;
use warnings;

my @available_layouts = qw(
  com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese
  com.apple.keylayout.ABC
  org.sil.ukelele.keyboardlayout.unsavedukeleledocument.keylayout.ABCProgramming
);

my $next = shift @ARGV;
exit($next && $next eq 'daemon' ? daemon() : change_layout($next));

sub change_layout {
  my $next = shift;
  my $curr = current_layout();

  # find the next layout unless given as input
  for my $i (0..(@available_layouts - 1)) {
    last if $next;
    $next = $available_layouts[$i + 1] if index($curr, $available_layouts[$i]) == 0;
  }

  # change to the next or last, depending on the current select layout
  $next = $available_layouts[0] if !$next or $next eq $curr;
  $next = $available_layouts[-1] if $next and $next eq $curr;

  system '/opt/homebrew/bin/im-select' => $next unless $next eq $curr;
  return $?;
}

sub daemon {
  # Kill any running daemons
  open my $PS, '-|', '/bin/ps', 'x', '-opid,command' or die $!;
  while (<$PS>) {
    kill(TERM => $1) && exit if /(\d+)\s.*im-select-next.pl daemon/ and $1 ne $$;
  }

  my $curr = current_layout();
  while (sleep 1) {
    my $next = current_layout();
    system '/opt/homebrew/bin/im-select' => $available_layouts[-1]
      if $next ne $available_layouts[-1] && $next =~ /ABC/;
  }
}

sub current_layout {
  my $curr = qx{/opt/homebrew/bin/im-select};
  chomp $curr;
  return $curr;
}
