#!/usr/bin/perl

#=========================================================================
#
# svn_graph.pl
#
# Usage:
# cat log.txt | svn_graph.pl > myfile.png
#
# Expects input in this format:
# 27 - 2007-09-30 13:22:17 - 184 - 8165
# This format is created from `svn_countlines.sh`, which can be downloaded
# from http://trac.flodhes.net/snippets
#
#=========================================================================

use strict;
use warnings;
use GD::Graph::mixed;

my $height = 400;
my $width  = 700;
my $format = 'png'; # png, gif, jpg, ...
my $bfont  = ['/usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf'];
my $font   = ['/usr/share/fonts/truetype/ttf-bitstream-vera/Vera.ttf'  ];
my @x;
my @lines;
my @files;
my $lines_max_value = 0;
my $files_max_value = 0;


### READ INPUT
warn "Reading input...\n";
INPUT:
while(<>) {
    chomp;
    my @elem = split /\s-\s/;

    ### check
    for my $n (0,2,3) {
        next INPUT unless($n =~ /^\d+$/mx);
    }

    ### ok data
    push @x, "r$elem[0]";
    push @files, $elem[2];
    push @lines, $elem[3];
    $files_max_value = $elem[2] if($files_max_value <= $elem[2]);
    $lines_max_value = $elem[3] if($lines_max_value <= $elem[3]);
}

### CREATE IMAGE
warn "Initializing the image...\n";
my $graph = new GD::Graph::mixed($width, $height);

### SET IMAGE PARAMS
warn "Setting image params...\n";
$graph->set( 
    transparent      => 0,

    title            => 'Number of lines/files pr. rev',
    line_width       => 2,
    values_format    => "%d",

    y1_label         => 'Lines',
    y1_max_value     => $lines_max_value * 1.1,
    y2_label         => 'Files',
    y2_max_value     => $files_max_value * 1.1,
    y_number_format  => "%d",
    two_axes         => 1,

    x_label          => 'Rev#',
    x_label_position => 1/2,
    x_label_skip     => int(@x/20),
    x_all_ticks      => 1,
);

### SET IMAGE COLOURS
$graph->set(
    boxclr           => "#f7f7f7",
    labelclr         => "#333333",
    fgclr            => "#555555",
    axislabelclr     => "#444444",
    textclr          => "#000000",
);

### SET IMAGE FONTS
$graph->set_title_font($bfont, 12);
$graph->set_x_label_font($bfont, 11);
$graph->set_y_label_font($bfont, 11);
$graph->set_x_axis_font($font, 10);
$graph->set_y_axis_font($font, 10);
                  
### PLOT
warn "Writing image to disk...\n";
$graph->plot([\@x, \@lines, \@files]) or die $graph->error;
binmode STDOUT;
print $graph->gd->$format;

### THE END
exit 0;
