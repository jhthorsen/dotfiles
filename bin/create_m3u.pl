#!/usr/bin/perl

#==============
# create_m3u.pl
#==============

use File::Find;
use strict;
use vars qw/
    $basedir $plistdir $baseurl $suffix $file_patt $join_patt $plist_id %list
/;

$basedir   = $ARGV[0] || '.';
$plistdir  = $ARGV[1] || './playlists';
$baseurl   = qq(http://yourdomain/music/);
$suffix    = '.m3u';
$file_patt = qr{\.mp3$}i;
$join_patt = qr{^0\.}i;
$|++;


### init
my $all   = '0.all';
my $other = '0.other';

### delete old playlists
unlink <$plistdir/*>;

### find files
for my $dir (listdir()) {
    $plist_id = ($dir =~ /$join_patt/) ? $other : $dir;
    find(\&found, "$basedir/$dir");
    writeplist($plist_id) unless($dir =~ /$join_patt/);
    push @{$list{$all}}, @{$list{$plist_id}};
}

### write common lists
writeplist($other);
writeplist($all);

### the end
return 0;


sub writeplist { #=============================================================

    ### init
    my $prefix = shift;

    ### status
    print "Writing $plistdir/$prefix$suffix\n";

    ### write
    open(PLS, '>', "$plistdir/$prefix$suffix") or die $!;
    print PLS qq(#EXTM3U\n);
    print PLS map {
        s/^\.//;
        s/\s/\%20/g;
        qq(http://home.flodhest.net/muz$_\n);
    } @{$list{$prefix}};
    close PLS;
}

sub found { #==================================================================

    ### check
    $File::Find::name =~ /$file_patt/ or return;

    ### push files
    push @{$list{$plist_id}}, $File::Find::name;
}

sub listdir { #================================================================

    ### get dir content
    opendir(DD, $basedir) or die $!;
    my @dd = sort grep { /^\w/ && -d $_ } readdir DD;
    close DD;

    ### the end
    return @dd;
}

#==============================================================================
1983;
