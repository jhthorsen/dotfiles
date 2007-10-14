#!/usr/bin/perl

#==============
# lwmwannabe.pl
#==============

use strict;
use warnings;
use Fcntl qw(S_ISBLK S_ISCHR S_ISFIFO SEEK_SET);
use File::Basename;
use Filesys::Df;
use Fuse;
use POSIX qw(
              EROFS     ENOENT  ENOSYS    EEXIST   EPERM
              O_RDONLY  O_RDWR  O_APPEND  O_CREAT
          );
require 'syscall.ph'; # for SYS_mknod and SYS_lchown

our $VERSION   = '0.01';
my $DEBUG      = 2;
my $ROOT       = join "", map { chr $_ } 0..255;
my $mtime      = time - 1;
my $mode       = 0775;
my $uid        = 0;
my $gid        = 0;
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
    threaded   => 1,
    debug      => $DEBUG,
);


sub debug { #=================================================================

    ### init
    my $msg  = shift || '';
    my $val  = shift;
    my $time = time;

    warn "$time ! $msg\n" if($DEBUG > 1);

    ### the end
    return $val;
}

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
            $source =~ s"/+$"";
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
    exit;
}

sub find_file { #=============================================================

    ### init
    my $file =  shift;
       $file =~ s"^/+"";

    ### root ?
    unless(length $file) {
        debug("Found root directory");
        return $ROOT;
    }

    ### cached file
    if($cache{$file} and -e $cache{$file}) {
        debug("File from cache: $file => $cache{$file}");
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
    debug("Found file: $file => " .($cache{$file} || ''));
    return $cache{$file} || '';
}

sub find_newfile { #==========================================================

    ### init
    my $oldfile = shift;
    my $newfile = shift;

    SOURCE:
    for my $source (@sources) {
        if($oldfile =~ m"^$source/"mx) {
            debug("New file from cache: $newfile => $cache{$newfile}");
            $cache{$newfile} = "$source/$newfile";;
            last;
        }
    }

    ### the end
    debug("Found new file: $newfile => $cache{$newfile}");
    return $cache{$newfile};
}

sub fuse_getattr { #==========================================================

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);
    my @stat;

    debug("Getattr $vfile");

    if($file eq $ROOT) {
        @stat = (
                    0,                   # device number
                    0,                   # inode number
                    (0040 << 9) + $mode, # file mode
                    1,                   # number of hard links
                    $uid,                # user id
                    $gid,                # group id
                    0,                   # device indentifier
                    0,                   # size
                    $mtime,              # last acess time
                    $mtime,              # last modified time
                    $mtime,              # last change time
                    1024,                # block size
                    0,                   # blocks
                );
    }
    else {
        @stat = lstat $file;
    }

    ### the end
    return -$! unless @stat;
    return @stat;
}

sub fuse_getdir { #===========================================================

    ### init
    my $vdir = shift;
    my $dir  = find_file($vdir);
    my($DH, @files);

    debug("Getdir $vdir");

    ### open, read, close dir
    if($dir eq $ROOT) {

        SOURCE:
        for my $source (@sources) {
            opendir($DH, $source) or next SOURCE;
            push @files, readdir $DH;
            close $DH;
        }
    }
    else {
        opendir($DH, $dir) or return -ENOENT();
        @files = readdir $DH;
    }

    ### the end
    return @files, 0;
}

sub fuse_open { #=============================================================

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile); 
    my $mode  = shift;
    my $FH;

    debug("Open $vfile");

    ### open file
    sysopen($FH, $file, $mode) or return -$!;
    return 0;
}

sub fuse_read { #=============================================================

    ### init
    my $vfile   = shift;
    my $file    = find_file($vfile);
    my $bufsize = shift;
    my $offset  = shift;
    my $size    = -s $file;
    my($FH, $read);

    debug("Read $vfile");

    ### check for file existence
    return -ENOENT() unless(defined $size);

    ### open and read file
    open($FH, $file)             or  return -ENOSYS();
    seek($FH, $offset, SEEK_SET) and read($FH, $read, $bufsize);

    ### the end
    return $read || -ENOSYS();
}

sub fuse_write { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile  = shift;
    my $file   = find_file($vfile);
    my $buffer = shift;
    my $offset = shift;
    my $size   = -s $file;
    my($FH, $ret);

    debug("Write $vfile");

    ### check for file existence
    return -ENOENT() unless(defined $size);

    ### open and write to file
    open($FH, "+<", $file)       or  return -ENOSYS();
    seek($FH, $offset, SEEK_SET) and $ret = print $FH $buffer;

    ### the end
    return $ret ? length $buffer : -ENOSYS();
}

sub fuse_readlink { #=========================================================

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);

    debug("Readlink $vfile");

    ### the end
    return readlink $file;
}

sub fuse_unlink { #===========================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);

    debug("Unlink $vfile");

    ### the end
    return unlink $file ? 0 : -$!;
}

sub fuse_symlink { #==========================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $oldfile = find_file(shift);
    my $newfile = find_newfile($oldfile, shift);

    debug("Symlink $oldfile => $newfile");

    ### the end
    return symlink $oldfile, $newfile ? 0 : -$!;
}

sub fuse_rename { #===========================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $old_name = find_file(shift);
    my $new_name = find_newfile(shift, $old_name);

    debug("Rename $old_name => $new_name");

    ### init
    my ($err) = rename($old_name, $new_name) ? 0 : -ENOENT();
    return $err;
}

sub fuse_link { #=============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $old_name  = find_file(shift);
    my $link_name = find_newfile(shift, $old_name);

    debug("Hardlink $old_name => $link_name");

    ### the end
    return link $old_name, $link_name ? 0 : -$!
}

sub fuse_chown { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);
    my $uid   = shift;
    my $gid   = shift;

    debug("Chown $vfile => $uid/$gid");

    ### the end (cannot use perl's chown)
    return syscall &SYS_lchown, $file, $uid, $gid, $file ? -$! : 0;
}

sub fuse_chmod { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);
    my $mode  = shift;

    debug("Chmod $vfile => $mode");

    ### the end
    return chmod $mode, $file ? 0 : -$!;
}

sub fuse_truncate { #=========================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile  = shift;
    my $file   = find_file($vfile);
    my $length = shift;

    debug("Truncate $vfile => $length");

    ### the end
    return truncate $file, $length ? 0 : -$!;
}

sub fuse_utime { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);
    my $atime = shift;
    my $mtime = shift;

    debug("Utime $vfile => $atime/$mtime");

    ### the end
    return utime $atime, $mtime, $file ? 0 : -$!;
}

sub fuse_mkdir { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vdir        = shift;
    my $dir         = find_newfile($vdir);
    my $permissions = shift;

    debug("Make dir $vdir ($permissions)");

    ### make dir
    mkdir $dir, $permissions or return -$!;

    ### the end
    return 0;
}

sub fuse_rmdir { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vdir = shift;
    my $dir  = find_file($vdir);

    debug("Remove dir $vdir");

    ### remove dir
    rmdir $dir or return -$!;

    ### the end
    return 0;
}

sub fuse_mknod { #============================================================
    return -EROFS() unless($READ_WRITE);

    ### init
    my $vfile = shift;
    my $file  = find_file($vfile);
    my $modes = shift;
    my $dev   = shift;
       $!     = 0;

    debug("Make node $vfile");

    ### the end
    syscall &SYS_mknod, $file, $modes, $dev;
    return -$!;
}

sub fuse_statfs { #===========================================================

    ### init
    my $total = {
                    blocks => 0, # total blocks
                    bfree  => 0, # total free blocks
                    used   => 0, # total used blocks
                    files  => 0, # total inodes
                    ffree  => 0, # total free inodes
                    fused  => 0, # total used inodes
                };

    debug("Statfs");

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
