#!/usr/bin/perl

=head1 NAME

colorgrep.pl - Highlight matching lines

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

=back

=head1 INSTALL DEPENDENCIES

 cpan -i Term::ANSIColor
 cpan -i Pod::Usage
 cpan -i Getopt::Long

=cut

use strict;
use warnings;
use Term::ANSIColor;
use Pod::Usage;
use Getopt::Long qw(
    :config auto_abbrev bundling pass_through auto_version auto_help
);

our $VERSION = 1.1;

my $color = 'red';
my $suppress = 0;
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

if(-t STDIN) {
    for my $file (@files) {
        open(my $FH, $file) or warn "Cannot open '$file': ($!)";
        print_line while(<$FH>);
    }
}
else {
    print_line while(readline STDIN);
}

exit 0;

=head1 FUNCTIONS

=head2 print_line

 print_line($line);

Print a line, with color if C<$regex> match.

=cut

sub print_line {
    local $_  = shift || $_;
    my $chomp = (chomp) ? 1 : 0;

    # print line that match
    if(/(.*?)($regex)(.*)/g) {
        print color($color), $1;
        print color('bold'), $2;
        print color('reset');
        print color($color), $3;
        print color('reset');
        print "\n" if($chomp);
    }
    
    # print line that doesn't match
    elsif(!$suppress) {
        print;
        print "\n" if($chomp);
    }
}

=head2 help

 help();

Print help, using L<Pod::Usage>.

=cut

sub help {
    pod2usage({
        -verbose  => 99,
        -sections => 'NAME|SYNOPSIS|TASK LIST|OPTIONS',
        -output   => \*STDOUT,
        -exitval  => 0
    });
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
