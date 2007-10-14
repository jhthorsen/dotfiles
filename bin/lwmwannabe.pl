#!/usr/bin/perl

#==============
# lwmwannabe.pl
#==============

use strict;
use warnings;
use Fuse;
use Filesys::Df;
use POSIX qw(ENOENT ENOSYS EEXIST EPERM O_RDONLY O_RDWR O_APPEND O_CREAT);
use Fcntl qw(S_ISBLK S_ISCHR S_ISFIFO SEEK_SET);
require 'syscall.ph'; # for SYS_mknod and SYS_lchown

our $VERSION   = '0.01';
my $READ_WRITE = argv_readwrite();
my $target     = argv_target();
my @sources    = argv_sources();
my %cache;

Fuse::main(
    mountpoint => $target,
    getattr    => "main::fuse_getattr",
    readlink   => "main::fuse_readlink",
    getdir     => "main::fuse_getdir",
    mknod      => "main::fuse_mknod",
    mkdir      => "main::fuse_mkdir",
    unlink     => "main::fuse_unlink",
    rmdir      => "main::fuse_rmdir",
    symlink    => "main::fuse_symlink",
    rename     => "main::fuse_rename",
    link       => "main::fuse_link",
    chmod      => "main::fuse_chmod",
    chown      => "main::fuse_chown",
    truncate   => "main::fuse_truncate",
    utime      => "main::fuse_utime",
    open       => "main::fuse_open",
    read       => "main::fuse_read",
    write      => "main::fuse_write",
    statfs     => "main::fuse_statfs",
    threaded   => 0,
    debug      => 1,
);


sub argv_readwrite { #========================================================

    ### READ WRITE NOT SUPPORTED YET!
    return 0;

    ARG:
    for my $i (0..@ARGV-1) {
        if($ARGV[$i] eq '-rw') {
            splice @ARGV, $i, 1;
            return 1;
        }
    }

    ### the end
    return 0;
}

sub argv_target { #===========================================================

    ### init
    my $target = pop @ARGV || '';

    ### no args
    unless(length $target) {
        usage();
    }

    ### make dir if non-existing
    unless(-d $target) {
        mkdir $target or die "Cannot makedir '$target': $!";
    }

    ### the end
    return $target;
}

sub argv_sources { #==========================================================

    ### init
    my @sources;

    SOURCE:
    for my $source (@ARGV) {
        unless(-d $source) {
            warn "Source '$source' is not a directory!\n";
        }
        else {
            push @sources, $source;
        }
    }

    ### check for sources
    unless(@sources) {
        usage();
    }
    
    ### the end
    return @sources
}

sub usage { #=================================================================

    ### print help
    print "Usage:\n";
    print " lwmwannabe.pl <sources> <target>\n";
    print "More info: 'perldoc $0`\n";

    ### the end
    exit 0;
}

sub find_file { #=============================================================

    ### init
    my $file = shift;

    ### cached file
    if($cache{$file} and -e $cache{$file}) {
        return $cache{$file};
    }

    SOURCE:
    for my $source (@sources) {
        if(-e "$source/$file") {
            $cache{$file} = "$source/$file";
            last;
        }
    }

    ### the end
    return $cache{$file};
}

sub find_newfile { #==========================================================

    ### init
    my $oldfile = shift;
    my $newfile = shift;

    SOURCE:
    for my $source (@sources) {
        if($oldfile =~ m"^$source/"mx) {
            $cache{$newfile} = "$source/$newfile";;
            last;
        }
    }

    ### the end
    return $cache{$newfile};
}

sub fuse_getattr { #==========================================================

    ### init
    my $file = find_file(shift);
    my @stat = lstat $file;

    ### the end
    return -$! unless @stat;
    return @stat;
}

sub fuse_getdir { #===========================================================

    ### init
    my $dir = find_file(shift);
    my($DH, @files);

    ### open, read, close dir
    opendir($DH, $dir) or return -ENOENT();
    @files = readdir $DH;

    ### the end
    return @files, 0;
}

sub fuse_open { #=============================================================

    ### init
    my $file = find_file(shift);
    my $mode = shift;
    my $FH;

    ### open file
    sysopen($FH, $file, $mode) or return -$!;
    return 0;
}

sub fuse_read { #=============================================================

    ### init
    my $file    = find_file(shift);
    my $bufsize = shift;
    my $offset  = shift;
    my $size    = -s $file;
    my($FH, $read);

    ### check for file existence
    return -ENOENT() unless(defined $size);

    ### open and read file
    open($FH, $file)             or  return -ENOSYS();
    seek($FH, $offset, SEEK_SET) and read($FH, $read, $bufsize);

    ### the end
    return $read || -ENOSYS();
}

sub fuse_write { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $file   = find_file(shift);
    my $buffer = shift;
    my $offset = shift;
    my $size   = -s $file;
    my($FH, $ret);

    ### check for file existence
    return -ENOENT() unless(defined $size);

    ### open and write to file
    open($FH, "+<", $file)       or  return -ENOSYS();
    seek($FH, $offset, SEEK_SET) and $ret = print $FH $buffer;

    ### the end
    return $ret ? length $buffer : -ENOSYS();
}

sub fuse_readlink { #=========================================================
    return readlink find_file(shift);
}

sub fuse_unlink { #===========================================================
    return -ENOENT() unless($READ_WRITE);
    return unlink find_file(shift) ? 0 : -$!;
}

sub fuse_symlink { #==========================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $oldfile = find_file(shift);
    my $newfile = find_newfile($oldfile, shift);

    ### the end
    return symlink $oldfile, $newfile ? 0 : -$!;
}

sub fuse_rename { #===========================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $old_name = find_file(shift);
    my $new_name = find_newfile(shift, $old_name);

    ### init
    my ($err) = rename($old_name, $new_name) ? 0 : -ENOENT();
    return $err;
}

sub fuse_link { #=============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $old_name  = find_file(shift);
    my $link_name = find_newfile(shift, $old_name);

    ### the end
    return link $old_name, $link_name ? 0 : -$!
}

sub fuse_chown { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $file = find_file(shift);
    my $uid  = shift;
    my $gid  = shift;

    ### the end (cannot use perl's chown)
    return syscall &SYS_lchown, $file, $uid, $gid, $file ? -$! : 0;
}

sub fuse_chmod { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $file = find_file(shift);
    my $mode = shift;

    ### the end
    return chmod $mode, $file ? 0 : -$!;
}

sub fuse_truncate { #=========================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $file   = find_file(shift);
    my $length = shift;

    ### the end
    return truncate $file, $length ? 0 : -$!;
}

sub fuse_utime { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $file  = find_file(shift);
    my $atime = shift;
    my $mtime = shift;

    ### the end
    return utime $atime, $mtime, $file ? 0 : -$!;
}

sub fuse_mkdir { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $new_dir     = find_newfile(shift);
    my $permissions = shift;

    ### make dir
    mkdir $new_dir, $permissions or return -$!;

    ### the end
    return 0;
}

sub fuse_rmdir { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $dir = find_file(shift);

    ### remove dir
    rmdir $dir or return -$!;

    ### the end
    return 0;
}

sub fuse_mknod { #============================================================
    return -ENOENT() unless($READ_WRITE);

    ### init
    my $file  = find_file(shift);
    my $modes = shift;
    my $dev   = shift;
       $!     = 0;

    ### the end
    syscall &SYS_mknod, $file, $modes, $dev;
    return -$!;
}

# kludge
sub fuse_statfs {

    ### init
    my $total = {
                    blocks => 0, # total blocks
                    bfree  => 0, # total free blocks
                    used   => 0, # total used blocks
                    files  => 0, # total inodes
                    ffree  => 0, # total free inodes
                    fused  => 0, # total used inodes
                };

    SOURCE:
    for my $source (@sources) {
        my $info      = df $source or next SOURCE;
        $total->{$_} += $info->{$_} for(keys %$total);
    }

    ### the end
    return(
        255,
        $total->{'files'},
        $total->{'ffree'},
        $total->{'blocks'},
        $total->{'bfree'},
        1024,
    );
}

#=============================================================================
exit 0;
__END__

=head1 NAME

lwmwannabe.pl - A fuse fs for multiple dirs inside one virtual dir

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

 lwmwannabe.pl <sources> <target>;
 lwmwannabe.pl path/to/source_1 \
               path/to/source_2 \
               ...              \
               path/to/source_n \
               /my/target       \
               ;

=head1 DESCRIPTION

This script allows you to collect the content of multiple directories into
one common directory.

lwnwannabe.pl is READ ONLY for now. The reason for this is that it's
difficult to know which of the sources that has sufficient amount of
diskspace.

=head1 DEPENDENCIES

=over 4

=item C<Fuse>

=item C<Filesys::Df>

=back

=head1 AUTHOR

Jan Henning Thorsen, C<< <pm at flodhest.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-snmp-effective at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=SNMP-Effective>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc SNMP::Effective

You can also look for information at: http://trac.flodhest.net/snippets

=head1 ACKNOWLEDGEMENTS

Various contributions by Oliver Gorwits.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jan Henning Thorsen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
