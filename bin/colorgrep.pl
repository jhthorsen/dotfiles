#!/usr/bin/perl

#=============
# colorgrep.pl
#=============

use strict;
use warnings;
use Term::ANSIColor;
use Pod::Usage;
use Getopt::Long  qw(:config auto_abbrev   bundling   pass_through
                             auto_version  auto_help
                    );
use vars          qw($VERSION);

$VERSION        = 1.0;
my $suppress    = 0;
my $ignore_case = 0;
my $color       = 'red';


#== GET COMMAND LINE ARGUMENTS ===============================================
GetOptions(
    qw'       help|h  ' => \&help,
    qw'   suppress|s  ' => \$suppress,
    qw'ignore_case|i  ' => \$ignore_case,
    qw'      color|c=s' => \$color,
);


#== INIT =====================================================================
my $regex = shift @ARGV or help();
my @files = @ARGV;

$regex    = ($ignore_case) ? qr{$regex}i : qr{$regex};


#== READ STDIN ===============================================================
print_line($_) while(<>);


#== LOOP FILES ===============================================================
for my $file (@files) {
    open(FH, $file) or warn "No such file $file ($!)";
    print_line($_) while(<FH>);
    close FH;
}


### the end
exit 0;


sub print_line { #============================================================

    ### init
    local $_  = shift;
    my $chomp = (chomp) ? 1 : 0;

    ### print line that match
    if(/(.*?)($regex)(.*)/) {
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

__END__

=head1 NAME

 colorgrep.pl - a way to highlight certain lines - http://flodhest.net/

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
