#!perl
use strict;

while(<>) {
  if (/^(---|\+\+\+|@@)\s*(.*)/) {
    print "\\$1\t$2\n";
  }
  elsif (/^(-|\+|[ ])(.*)/) {
    print "\\$1\t$2\n";
  }
  else {
    print;
  }
}
