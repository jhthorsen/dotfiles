#!/usr/bin/perl

=head1 NAME

svn-graph.pl - Create GD graphs from a SVN repo

=head1 SYNOPSIS

 $ svn-countlines.pl | svn-graph.pl > myfile.png;
 $ cat log.txt | svn-graph.pl > myfile.png

Expects format in C<log.txt>:

 27 - 2007-09-30 13:22:17 - 184 - 8165

=head1 INSTALL DEPENDENCIES

 cpan -i GD::Graph;

=cut

use strict;
use warnings;
use GD::Graph::mixed;

my $bfont = ['/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf'];
my $font = ['/usr/share/fonts/truetype/ttf-bitstream-vera/Vera.ttf'  ];

exit main(
    dimensions => [ 400, 700 ], # height, width
    format => 'png',
);

=head1 FUNCTIONS

=head2 main

 $exit_code = main( dimensions => [$height, $width], format => $str );

Will read logfile and print graph.

=cut

sub main {
    my %args = @_;
    my $format = $args{'format'};
    my $lines_max_value = 0;
    my $files_max_value = 0;
    my(@x, @lines, @files);

    debug("Read input");

    INPUT:
    while(<>) {
        chomp;
        my @elem = split /\s-\s/;

        for my $n (0,2,3) {
            next INPUT unless($n =~ /^\d+$/mx);
        }

        push @x, "r$elem[0]";
        push @files, $elem[2];
        push @lines, $elem[3];

        $files_max_value = $elem[2] if($files_max_value <= $elem[2]);
        $lines_max_value = $elem[3] if($lines_max_value <= $elem[3]);
    }

    debug("Initialize image");

    my $graph = init_graph(
                    files_max_value => $files_max_value,
                    lines_max_value => $lines_max_value,
                    x_label_skip => int(@x / 5),
                    dimensions => $args{'dimensions'},
                );

    debug("Writing image");

    $graph->set_legend('Lines', 'Files');
    $graph->plot([\@x, \@lines, \@files]) or die $graph->error;

    binmode STDOUT;
    print $graph->gd->$format;

    return 0;
}

=head2 init_graph

 $gd_graph = init_graph(
                 dimensions => [$height, $width],
                 lines_max_value => $int,
                 files_max_value => $int,
                 x_label_skip => $int,
             );

Returns a L<GD::Graph> object.

=cut

sub init_graph {
    my %args = @_;
    my $graph = GD::Graph::mixed->new(@{ $args{'dimensions'} });

    debug("Setting image params...");

    $graph->set( 
        transparent      => 0,

        title            => 'Number of lines/files pr. rev',
        line_width       => 2,
        values_format    => "%d",

        y1_label         => 'Lines',
        y1_max_value     => $args{'lines_max_value'} * 1.1,
        y2_label         => 'Files',
        y2_max_value     => $args{'files_max_value'} * 1.1,
        y_number_format  => "%d",
        two_axes         => 1,

        x_label          => 'Rev#',
        x_label_position => 1/2,
        x_label_skip     => $args{'x_label_skip'},
        x_all_ticks      => 1,
    );

    $graph->set(
        boxclr           => "#f7f7f7",
        labelclr         => "#333333",
        fgclr            => "#555555",
        axislabelclr     => "#444444",
        textclr          => "#000000",
        legendclr        => "#555555",
    );

    $graph->set_title_font($bfont, 12);
    $graph->set_legend_font($bfont, 10);
    $graph->set_x_label_font($bfont, 11);
    $graph->set_y_label_font($bfont, 11);
    $graph->set_x_axis_font($font, 10);
    $graph->set_y_axis_font($font, 10);

    return $graph;
}

=head2 debug

 debug($str);

Print C<$str> to STDERR.

=cut

sub debug {
    print STDERR $_[0], "\n";
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
