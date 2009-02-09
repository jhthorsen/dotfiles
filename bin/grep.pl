#!/usr/bin/env perl

use strict;
use warnings;
use File::Find;
use Getopt::Long qw(:config auto_help auto_version);

our $VERSION = "0.03";

=head1 NAME

grep.pl - Does recursive search/grepping in text-files

=head1 DESCRIPTION

=head2 Why? 

 Why do grep-regex, when you can do perl-regex?

 Why run...
 $ find . | grep -v ".svn" | \
   grep -v "pm$" | xargs grep $GREPRE
 ...when you can do C<grep.pl $PERLRE>?

=head2 Is it slow?

Seems pretty fast... at perl-regex is at least just as fast as grep-regex.

=head2 perl-regex?

Yes! C<grep.pl> is pure Perl.

=head1 SYNOPSIS

 grep.pl [options] <search> 

=over 4

=item --dir=PATH, -d

Default is "current dir".

=item --name=PERLRE, -n

Default is C<pm$> - Regex to match only certain files.

=item --regex-options, -r

Same as you would have after m//. Example: ix

=item --list, -l

Only list files that match

=item --skip=PERLRE, -s

Skip certain files. Default is C</.svn/> (...and C</RCS/>)

=item --summary

Print summary to STDERR.

=item --color=COLOR

Print matching string in colors.

COLOR can be: clear, reset, dark, bold, underline, underscore, blink,
reverse, concealed, black, red, green, yellow, blue, magenta, cyan, white,
on_black, on_red, on_green, on_yellow, on_blue, on_magenta, on_cyan,
and on_white

=back

=cut

my $dir       = q(.);
my $name      = q(pm$);
my $re_opt    = q();
my $skip      = q(/.svn/|/RCS/|/.git/);
my $list_only = 0;
my $summary   = 0;
my $total     = 0;
my $found     = 0;
my $color     = q();
my $started   = time;
my $columns   = $ENV{'COLUMNS'} || 80;

Getopt::Long::GetOptions(
    'dir|d=s'           => \$dir,
    'name|n=s'          => \$name,
    'regex-options|r=s' => \$re_opt,
    'list|l'            => \$list_only,
    'skip=s'            => \$skip,
    'color=s'           => \$color,
    'summary'           => \$summary,
);
my $search = pop or exit Getopt::Long::HelpMessage();

$name   = qr{(?:$name)};
$search = qr{(?$re_opt:$search)};
$skip   = qr{(?:$skip)};

if($color) {
    eval "require Term::ANSIColor" or die $@;
    Term::ANSIColor->import;
}

find(sub {
    $File::Find::name =~ /$skip/ and return;
    $File::Find::name =~ /$name/ or  return;
    open(my $FILE, "<", $_)      or  return;
    $total++;

    if($list_only) {
        while(readline $FILE) {
            if(/$search/) {
                print "$File::Find::name\n";
                $found++;
                return;
            }
        }
    }
    elsif($color) {
        while(my $line = readline $FILE) {
            my $out = q();
            while($line =~ s/\G(.*)($search)//) {
                $out .= $1 .color($color) .$2 .color('reset');
            }
            my $rest = ($line =~ /\G(.*)/)[0] || q();
            next unless($out);
            print "$File::Find::name: $out$rest\n";

        }
    }
    else {
        while(readline $FILE) {
            if(/$search/) {
                $found++;
                print "$File::Find::name: $_";
            }
        }
    }
}, $dir);

if($summary) {
    if($list_only) {
        printf STDERR ("Used %i second(s). Matched %i of %i files\n",
            (time - $started), $found, $total
        );
    }
    else {
        printf STDERR ("Used %i second(s). %i matching lines in %i files\n",
            (time - $started), $found, $total
        );
    }
}

exit !$found;

=head1 AUTHOR

Jan Henning Thorsen

=cut
