#!/usr/bin/perl

#================
# filename2id3.pl
#================

use strict;
use warnings;
use MP3::Tag;
use File::Find;
use File::Basename;

$|++;
my $path_seperator = ($^O =~ /linux/i) ? '/' : ':';
my $info_seperator = qr{\s+-\s+};

### loop files
#for(sort @{ MP3::Tag->genres }) {
#    print "$_\n";
#}

find(\&filename2id3, ".");

### the end
exit 0;


sub filename2id3 { #==========================================================

    ### init
    my $filename                = $_;
    my($track, $artist, $title) = split /$info_seperator/, $filename;
    my($artist_regex, $album);

    ### check file
    return unless($title and $artist      );
    return unless($title =~ s/\.mp3$//i   );
    return unless($track =~ s/^0(\d+)$/$1/);

    ### find album
    $artist_regex =  $artist;
    $artist_regex =~ s/([\[\(\)\]])/\\$1/g;
    $artist_regex =  qr{$artist_regex};
    for my $d (reverse split m{$path_seperator}, $File::Find::dir) {
        $d     =~ s/$artist_regex$info_seperator// or  next;
        $album = $d                                and last;
    }

    ### check album
    return unless($album);

    ### read file
    my $mp3   = MP3::Tag->new($filename);
    my $id3v2 = $mp3->{'ID3v2'} || $mp3->new_tag('ID3v2');

    ### set id3
    $id3v2->track  or $id3v2->track($track);
    $id3v2->album  or $id3v2->album($album);
    $id3v2->artist or $id3v2->artist($artist);
    $id3v2->title  or $id3v2->title($title);
    $id3v2->write_tag;

    printf "%02s - %s - %s - %s\n",
           $id3v2->track,
           $id3v2->artist,
           $id3v2->album,
           $id3v2->title
           ;
}
