#!/usr/bin/env perl
package Fuse::FilterFs;
use strict;
use warnings;
use experimental qw(signatures);

use Fcntl qw(SEEK_SET);
use File::Basename qw(basename);
use File::Spec::Functions qw(catfile);
use Fuse;
use POSIX qw(ENOENT ENOSYS);

# Attributes
sub block_size  ($self) { $self->{block_size}  || 4096 }
sub exclude     ($self) { $self->{exclude}     || {} }
sub max_namelen ($self) { $self->{max_namelen} || 255 }
sub mountopts   ($self) { $self->{mountopts}   || '' }
sub source      ($self) { $self->{source}      || die "source is required" }

# Fuse methods
sub handle_chmod ($self, $rel, $modes) {
  return -ENOENT unless my $abs = $self->resolve_file(chmod => $rel);
  return chmod($modes, $abs) ? 0 : -$!;
}

sub handle_chown ($self, $rel, $uid, $gid) {
  return -ENOENT unless my $abs = $self->resolve_file(chown => $rel);
  return chown($uid, $gid, $abs) ? 0 : -$!;
}

sub handle_create ($self, $rel, $modes, $flags, $info_hash = {}) {
  return -ENOENT unless my $abs = $self->resolve_file(create => $rel);
  return -$!     unless sysopen my ($fh), $abs, $flags;
  return -$!     unless chmod $modes, $abs;
  return (0, $fh);
}

sub handle_getattr ($self, $rel) {
  return -ENOENT unless my $abs = $self->resolve_file(getattr => $rel);
  return -e $abs ? stat $abs : -ENOENT;
}

sub handle_getdir ($self, $rel) {
  return -ENOENT unless my $abs = $self->resolve_file(getdir => $rel);
  return -$!     unless opendir(my $DH, $abs);

  $rel =~ s!/$!!;
  my @names = grep { $self->resolve_file(readdir => "$rel/$_") } readdir $DH;
  return @names, 0;
}

sub handle_link ($self, $rel, $name) {
  return -ENOENT unless my $abs = $self->resolve_file(link => $rel);
  return link($abs, $name) ? 0 : -$!;
}

sub handle_mkdir ($self, $rel, $modes) {
  return -ENOENT unless my $abs = $self->resolve_file(mkdir => $rel);
  return mkdir($abs, $modes) ? 0 : -$!;
}

sub handle_open ($self, $rel, $modes, $info_hash = {}) {
  return -ENOENT unless my $abs = $self->resolve_file(open => $rel);
  return -$! unless sysopen my ($fh), $abs, $modes;
  return (0, $fh);
}

sub handle_read ($self, $rel, $bufsize, $offset, $fh = undef) {
  return -ENOSYS unless $fh;
  return -$!     unless sysseek $fh, $offset, SEEK_SET;
  return -$!     unless sysread $fh, my ($buf), $bufsize;
  return $buf;
}

sub handle_read_buf ($self, $rel, $size, $offset, $bufvec, $fh = undef) {
  return -ENOSYS unless $fh;
  return -$! unless sysseek $fh, $offset, SEEK_SET;
  my $rv = $bufvec->[0]{size} = sysread $fh, $bufvec->[0]{mem}, $size;
  return $rv;
}

sub handle_readlink ($self, $rel) {
  return -ENOENT unless my $abs = $self->resolve_file(readlink => $rel);
  return readlink($abs) // -$!;
}

sub handle_release    ($self, @) {0}
sub handle_releasedir ($self, @) {0}

sub handle_rename ($self, $rel, $name) {
  return -ENOENT unless my $abs_from = $self->resolve_file(rename => $rel);
  return -ENOENT unless my $abs_to = $self->resolve_file(rename => $name);
  rename($abs_from, $abs_to) ? 0 : -$!;
}

sub handle_rmdir ($self, $rel) {
  return -ENOENT unless my $abs = $self->resolve_file(rmdir => $rel);
  rmdir($abs) ? 0 : -$!;
}

sub handle_statfs ($self, @) {
  return ($self->max_namelen, 128, 1024, 1000000, 500000, $self->block_size);
}

sub handle_symlink ($self, $rel, $name) {
  return -ENOENT unless my $abs = $self->resolve_file(symlink => $rel);
  return symlink($abs, $name) ? 0 : -$!;
}

sub handle_truncate ($self, $rel, $len) {
  return -ENOENT unless my $abs = $self->resolve_file(truncate => $rel);
  return truncate($abs, $len) ? 0 : -$!;
}

sub handle_unlink ($self, $rel) {
  return -ENOENT unless my $abs = $self->resolve_file(unlink => $rel);
  return unlink($abs) ? 0 : -$!;
}

sub handle_utime ($self, $rel, $atime, $mtime) {
  return -ENOENT unless my $abs = $self->resolve_file(utime => $rel);
  return utime($atime, $mtime, $abs) ? 0 : -$!;
}

sub handle_write ($self, $rel, $buf, $offset, $fh = undef) {
  return -ENOENT unless $fh;
  return -$!     unless sysseek $fh, $offset, SEEK_SET;
  return -$!     unless defined(my $len = syswrite $fh, $buf);
  return $len;
}

sub handle_write_buf ($self, $rel, $offset, $bufvec, $fh = undef) {
  return -ENOENT unless $fh;
  return -$! unless sysseek $fh, $offset, SEEK_SET;

  # Copy paste from Fuse.pm example
  if ($#$bufvec > 0 || $bufvec->[0]{flags} & Fuse::FUSE_BUF_IS_FD) {
    my $single
      = [{flags => 0, fd => -1, mem => undef, pos => 0, size => Fuse::fuse_buf_size($bufvec)}];
    Fuse::fuse_buf_copy($single, $bufvec);
    $bufvec = $single;
  }

  return -$! unless defined(my $len = syswrite $fh, $bufvec->[0]{mem});
  return $len;
}

# These functions are not supported:
# sub handle_access ($self, @) { ENOSYS }
# sub handle_bmap ($self, @) { ENOSYS }
# sub handle_fallocate ($self, @) { ENOSYS }
# sub handle_fgetattr ($self, @) { }
# sub handle_flock ($self, @) { ENOSYS }
# sub handle_flush ($self, @) { ENOSYS }
# sub handle_fsync ($self, @) { ENOSYS }
# sub handle_fsyncdir ($self, @) { ENOSYS }
# sub handle_ftruncate ($self, @) { ENOSYS }
# sub handle_getxattr ($self, @) { ENOSYS }
# sub handle_ioctl ($self, @) { ENOSYS }
# sub handle_listxattr ($self, @) { ENOSYS }
# sub handle_lock ($self, @) { ENOSYS }
# sub handle_mknod ($self, @) { ENOSYS }
# sub handle_poll ($self, @) { ENOSYS }
# sub handle_removexattr ($self, @) { ENOSYS }
# sub handle_setxattr ($self, @) { ENOSYS }
# sub handle_utimens ($self, @) { ENOSYS }

# Methods
sub new ($class, %attrs) { bless \%attrs, $class }

sub resolve_file ($self, $op, $rel) {
  my $basename = basename $rel;
  return undef if $self->{exclude}{$op}{$basename};
  $rel =~ s!^/!!;
  return catfile $self->{source}, $rel;
}

sub start ($self, $mountpoint) {

  my $has_threads = 0;
  #eval {
  #  require threads;
  #  require threads::shared;
  #  threads->import;
  #  threads::shared->import;
  #  $has_threads = 1;
  #} or do {
  #  warn "Threads are not supported: $@" if $self->{debug};
  #};

  die "Invalid source: $self->{source}\n" unless -d $self->{source};
  die "Invalid mountpoint: $mountpoint\n" unless -d $mountpoint;

  Fuse::main(
    debug      => $self->{debug} > 2 ? 1 : 0,
    mountopts  => $self->mountopts,
    mountpoint => $mountpoint,
    threaded   => $has_threads,
    (map { ($_ => $self->_make_handler($_)) } $self->supported_fuse_functions),
  );
}

sub supported_fuse_functions ($self) {
  return grep { $self->can("handle_$_") } qw(access bmap chmod chown create destroy fallocate),
    qw(fgetattr flock flush fsync fsyncdir ftruncate getattr),
    qw(getdir getxattr init ioctl link listxattr lock mkdir),
    qw(mknod open opendir poll read read_buf readdir readlink),
    qw(release releasedir removexattr rename rmdir setxattr),
    qw(statfs symlink truncate unlink utime utimens write write_buf);
}

sub _make_handler ($self, $name) {
  my $handler = "handle_$name";
  return sub {
    my @ret = $self->$handler(@_);
    warn sprintf "%s %s == %s\n", $name, join(', ', map { $_ // 'undef' } @_),
      join(', ', map { $_ // 'undef' } @ret)
      if $self->{debug} > 1;
    return wantarray ? @ret : $ret[0];
  };
}

#==============================================================================
package main;
use strict;
use warnings;
use experimental qw(signatures);

use Data::Dumper ();
use Getopt::Long;
use Pod::Usage qw(pod2usage);

exit 1
  unless GetOptions
  'd+'            => \my $debug,
  'e|exclude=s@'  => \my @exclude,
  'h|help',       => \my $help,
  'o|mountopts=s' => \my $mountopts;

my ($source, $mountpoint) = @ARGV;

exit usage(0) if $help;
exit usage(0) unless $source and $mountpoint;
exit main();

sub build_exclude {
  my %exclude;
  for my $f (@exclude) {
    my ($op, $names) = split '=', $f, 2;
    next unless $op and $names;
    $exclude{$op}{$_} = 1 for grep {length} split /,/, $names;
  }

  return \%exclude;
}

sub d { Data::Dumper->new([@_])->Indent(1)->Pair(': ')->Sortkeys(1)->Terse(1)->Useqq(1)->Dump }

sub main {
  $debug     //= 0;
  $mountopts //= '';
  $mountpoint =~ s!/$!!;

  my $fs = Fuse::FilterFs->new(
    exclude   => build_exclude(),
    debug     => $debug,
    mountopts => $mountopts,
    source    => $source
  );
  if ($debug) {
    warn "Mounting $source to $mountpoint, with the following exclude rules:\n";
    warn d($fs->exclude);
  }

  system umount => $mountpoint if qx{mount} =~ m!\Q$mountpoint\E!;
  $fs->start($mountpoint);
  return 0;
}

sub usage ($exit = undef) {
  open my $OUT, '>', \my $output;
  pod2usage -exitval => 'noexit', -input => __FILE__, -output => $OUT;
  $output =~ s!^\s*Usage:!!;
  $output =~ s!^[ ]{4}!!mg;
  print $output;
  return $exit;
}

__END__

=head1 SYNOPSIS

  Usage:

    $ filterfs.pl -h
    $ filterfs.pl -e readdir=node_modules,.snapshots /source/path /dest/path

  Options:
    -e, --exclude    Exclude a file/directorie
    -o, --mountopts  Comma separated list of mount options
    -d               Normal debug output
    -d -d -d         Verbose debug output
    -h               Show this help text

  Exclude rules:

    An exclude rule must have a valid operation and a filename.
    Supported operations are:

      chmod, chown, create, getattr, getdir, link, mkdir, open, opendir, read,
      readdir, read_buf, readdir, readlink, rename, rmdir, symlink, truncate,
      unlink, utime, write, and write_buf.

   Multiple basenames can be separated by comma.

=cut
