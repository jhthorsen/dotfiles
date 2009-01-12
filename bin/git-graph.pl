#!/usr/bin/perl

=head1 NAME

git-graph.pl

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

 $ git-graph.pl --outfile <filename.png>

=head2 OPTIONS

 --outfile  : 
 --height   : 
 --width    : 
 --format   : 

=cut

use strict;
use warnings;
use GD::Graph::mixed;
use Getopt::Long qw/:config auto_version auto_help/;

my @GIT_LOG  = (qw(git-log --reverse --numstat -b), q(--pretty=format:---));
my $FONT_DIR = q(/usr/share/fonts/truetype/ttf-bitstream-vera);
my $ARGS = {
    height   => 500,
    width    => 700,
    max      => 0,
    title    => q(Lines in project),
    bfont    => [ "$FONT_DIR/VeraBd.ttf" ],
    font     => [ "$FONT_DIR/Vera.ttf"   ],
    outfile  => undef,
};

GetOptions($ARGS, qw/
    height|h=i width|w=i format|f outfile|o=s debug
/) or exit Getopt::Long::HelpMessage();

if($ARGS->{'outfile'}) {
    exit main();
}
else {
    exit Getopt::Long::HelpMessage();
}

=head1 FUNCTIONS

=head2 main

Parses this output from C<git-log>.

=cut

sub main {
    my $re_stats = qr{^\s*(\d+)\s+(\d+)\s+(.*)}i;
    my $i        = 0;
    my(%lines, %tmp);

    open(my $GITLOG, "-|", @GIT_LOG) or die "Could not run git-log: $!\n";

    warn "Running: @GIT_LOG\n";

    while(readline $GITLOG) {
        if(/$re_stats/) {
            my($added, $deleted, $name) = ($1, $2, $3);
            my $type = _category($name);

            if($type eq 'other') {
                warn "Unknown file: $name\n" if $ARGS->{'debug'};
            }

            $tmp{$type} ||= 0;
            $tmp{$type}  += ($added - $deleted);
        }
        elsif(/^---/ and %tmp) {
            for my $k (keys %tmp) {
                my $lines = ($lines{$k} ||= [0]);
                my @extra = (($lines->[-1]) x ($i - @$lines + 1));

                push @$lines, @extra, $lines->[-1] + $tmp{$k};

                if($ARGS->{'max'} < $lines->[-1]) {
                    $ARGS->{'max'} = $lines->[-1];
                }
            }

            %tmp = ();
            $i++;
        }
    }

    close $GITLOG or die "Could not end git-log properly: $!\n";

    graph(\%lines);

    exit 0;
}

sub _category {
    my $name = shift || q();
    my %cat  = (
        qr{js$}     => 'web',
        qr{css$}    => 'web',
        qr{tt$}     => 'web',
        qr{formfu}  => 'web',
        qr{t$}      => 'test',
        qr{yml$}    => 'config',
        qr{yaml$}   => 'config',
        qr{conf$}   => 'config',
        qr{sh$}     => 'script',
        qr{pl$}i    => 'script',
        qr{pm$}     => 'pm',
    );

    for(keys %cat) {
        $name =~ /$_/ and return $cat{$_};
    }

    return q(other);
}

=head2 graph

=cut

sub graph {
    my $lines = shift;
    my $img   = new GD::Graph::mixed($ARGS->{'width'}, $ARGS->{'height'});
    my $x     = (values %$lines)[0];

    $x = [1..@$x];
    my $v = [map { $_ % 10 ? 1 : undef } 1..@$x];

    $img->set( 
        transparent      => 0,
        title            => $ARGS->{'title'},
        line_width       => 2,
        r_margin         => 30,
        values_format    => "%d",

        y_number_format  => q(%d),
        y1_label         => q(Lines),
        y1_max_value     => $ARGS->{'max'} * 1.1,
       #y2_label         => 'Files',
       #y2_max_value     => $files_max_value * 1.1,
       #two_axes         => 1,

        x_label          => q(Time),
        x_all_ticks      => 1,
       #x_label_position => 1,
       #x_label_skip     => int(@$x/12),
        x_tick_number    => 'auto',

        boxclr           => q(#f7f7f7),
        labelclr         => q(#333333),
        fgclr            => q(#555555),
        axislabelclr     => q(#444444),
        textclr          => q(#000000),
        legendclr        => q(#555555),
    );

    $img->set_title_font($ARGS->{'bfont'}, 12);
    $img->set_legend_font($ARGS->{'bfont'}, 10);
    $img->set_x_label_font($ARGS->{'bfont'}, 11);
    $img->set_y_label_font($ARGS->{'bfont'}, 11);
    $img->set_x_axis_font($ARGS->{'font'}, 10);
    $img->set_y_axis_font($ARGS->{'font'}, 10);
                  
    $img->set_legend(sort keys %$lines);
    $img->plot(
        [$x, map { $lines->{$_} } sort keys %$lines]
    ) or die $img->error, "\n";

    my($format) = $ARGS->{'outfile'} =~ /\.(\w+)$/;

    print STDERR "Writing $ARGS->{'outfile'}\n" if $ARGS->{'debug'};
    open(my $IMG, ">", $ARGS->{'outfile'}) or die "Cannot write image: $!\n";
    print $IMG $img->gd->$format;
    close $IMG;

    return;
}

=head1 AUTHOR

Jan Henning Thorsen C< git at flodhest.net >;

=cut
