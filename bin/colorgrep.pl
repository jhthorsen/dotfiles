#!/usr/bin/perl

#=============
# colorgrep.pl
#=============

use strict;
use warnings;
use Term::ANSIColor;
use Pod::Usage;
use Getopt::Long qw(:config auto_abbrev   bundling   pass_through
                            auto_version  auto_help
                   );

our $VERSION    = 1.1;
my $color       = 'red';
my $suppress    = 0;
my $ignore_case = 0;
my($regex, @files);

GetOptions(
    qw'       help|h  ' => \&help,
    qw'   suppress|s  ' => \$suppress,
    qw'ignore_case|i  ' => \$ignore_case,
    qw'      color|c=s' => \$color,
);

$regex = shift @ARGV or help();
$regex = $ignore_case ? qr{$regex}i : qr{$regex};
@files = @ARGV;


### read from stdin
unless(-t STDIN) {
    print_line($_) while(readline STDIN);
}

### loop files
else {
    for my $file (@files) {
        open(FH, $file) or warn "Cannot open '$file': ($!)";
        print_line($_) while(<FH>);
        close FH;
    }
}

exit 0;


sub print_line { #============================================================

    local $_  = shift;
    my $chomp = (chomp) ? 1 : 0;

    ### print line that match
    if(/(.*?)($regex)(.*)/g) {
        print color($color), $1;
        print color('bold'), $2;
        print color('reset');
        print color($color), $3;
        print color('reset');
        print "\n" if($chomp);
    }
    
    ### print line that doesn't match
    elsif(!$suppress) {
        print;
        print "\n" if($chomp);
    }
}

sub help { #==================================================================
    pod2usage({
        -verbose  => 99,
        -sections => 'NAME|SYNOPSIS|TASK LIST|OPTIONS',
        -output   => \*STDOUT,
        -exitval  => 0
    });
}

#=============================================================================
__END__

=head1 NAME

colorgrep.pl - a way to highlight certain lines - http://trac.flodhest.net/

=head1 SYNOPSIS

 colorgrep.pl [args] <regexp> <files>

=head1 OPTIONS

=over 2

=item B<--suppress|-s>

 Do not print lines that doesn't match

=item B<--ignore_case|-i>

 Self explained, i hope :)

=item B<--color|-c>

 Which color to print matched lines with:
 reset, dark, underline, underscore, blink, concealed,
 black, red, green, yellow, blue, magenta,
 on_black, on_red, on_green, on_yellow, on_blue, on_magenta

=item B<--help|-h>

 This help message

=cut
