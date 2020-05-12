#!/usr/bin/env perl
use Applify;
use Mojo::Log;
use Mojo::File qw(path tempfile);
use Mojo::IOLoop::ReadWriteFork;

option flag => eject   => 'Use --no-eject to keep the dvd player closed after cloning', 1;
option str  => format  => 'Output file format',                                         'mkv';
option str  => preset  => 'Name of HandBrakeCLI preset',                                '';
option flag => dry_run => 'Do not run any commands',                                    0;
option int  => verbose => 'Verbosity level',                                            0;

sub clone {
  my ($self, $device) = @_;
  $self->set_temp_dir_once(path);

  $self->logf(info => 'Waiting for DVD device %s ...', $device);
  delete $self->{exif}{$device} until sleep 1 && $self->exif($device, 'File Type');

  my $type = lc $self->exif($device, 'File Type');
  die "Invalid type: $type.\n";

  my $date = $self->exif($device, 'Volume Create Date');
  $date =~ s!(\d{4})-(\d{2})-(\d{2})!$1$2$3!;
  $date =~ s!.00\+0\d-00!!;

  my $size = $self->exif($device, 'Volume Size');
  $size =~ s!(\d)\.(\d)\sGB!${1}${2}00MB!;
  $size =~ s!\sMB!MB!;

  my $out_file = join '_', $date, $self->exif($device, 'Volume Name'), $size, $type;
  $self->logf(info => 'ISO file "%s" %s.', $out_file, -e $out_file ? 'exists' : 'will be created');
  return 1 if -e $out_file;

  my $tmp       = $self->_tmp;
  my $exit_code = $self->_run(ddrescue => qw(-b 4096 -r 0 -n) => $device, $tmp);
  $self->_run(eject => $device) if !$exit_code and $self->eject;

  $self->logf(info => 'Move temp file "%s" to "%s".', $tmp, $out_file);
  path($tmp)->move_to($out_file) unless $exit_code;

  return $exit_code;
}

sub convert {
  my ($self, $file) = @_;
  $self->set_temp_dir_once(path($file)->dirname);

  my $out_file = sprintf '%s.%s', $file, $self->format;
  $self->logf(info => 'Video file "%s" %s.', $out_file, -e $out_file ? 'exists' : 'will be created');
  return 1 if -e $out_file;

  my $tmp       = $self->_tmp(SUFFIX => sprintf '.%s', $self->format);
  my @handbrake = qw(HandBrakeCLI -m);
  push @handbrake, qw(--decomb);
  push @handbrake, '--input'  => $file;
  push @handbrake, '--output' => $tmp;
  push @handbrake, '--format' => $self->format;

  # Preset that seems to work: "H.264 MKV 720p30"
  if ($self->preset) {
    push @handbrake, '--preset' => $self->preset;
  }
  elsif ($self->format eq 'mp4') {
    # TODO
  }
  else {
    push @handbrake, qw(-e x264 --x264-preset slow --x264-tune film --x264-profile main -q 23 -2 -T);
  }

  my $verbose = $self->verbose;
  $self->logf(info => '$ %s', join ' ', map { /\s/ ? qq('$_') : $_ } @handbrake);
  my $fork = Mojo::IOLoop::ReadWriteFork->new;

  my $buf = '';
  $fork->on(read => sub {
    my ($fork, $bytes) = @_;
    $buf .= $bytes;

    while ($buf =~ s!^(\r?.*\n\r?)!!) {
      local $_ = $1;
      next if !$verbose and m!CHECK_VALUE|dsi_gi.zero1!;
      next if !$verbose and m!^\s*$!;
      s!(Encoding.*)[\n\r]!$1\r!s;
      local $| = 1;
      print;
    }
  });

  my $exit_code = 1;
  $fork->on(close => sub { $exit_code = $_[1]; Mojo::IOLoop->stop });
  $fork->on(error => sub { $self->logf(error => 'HandBrakeCLI: %s', $_[1]) });
  $fork->run(@handbrake);
  Mojo::IOLoop->start;

  print "\n";
  $self->logf(info => 'Move temp file "%s" to "%s".', $tmp, $out_file);
  path($tmp)->move_to($out_file) unless $exit_code;
  return $exit_code;
}

sub convert_all {
  my ($self, $dir) = @_;
  $self->set_temp_dir_once(path($dir));

  opendir my $DH, $dir or die "opendir $dir: $!";
  while (my $file = readdir $DH) {
    eval {
      $self->convert($file) if $file =~ m!\.iso$!i;
      1;
    } or do {
      $self->logf(error => 'convert(%s) FAIL %s', $file, $@);
    };
  }

  return 0;
}

sub exif {
  my ($self, $file, $key) = @_;

  $self->{exif}{$file} //= '';
  unless ($self->{exif}{$file}) {
    my $tmp = $self->_tmp;
    $self->logf(debug => '$ exiftool %s > %s', $file, $tmp);
    system "exiftool $file > $tmp";
    $self->{exif}{$file} = $tmp->slurp;
  }

  return $self->{exif}{$file} =~ m!$key\s*:\s*(.*)!i ? $1 : '';
}

sub logf {
  my ($self, $level, $format, @args) = @_;
  my $log = $self->{log} ||= Mojo::Log->with_roles('+Color')->new;
  return $log->$level(@args ? sprintf $format, @args : $format);
}

sub set_temp_dir_once {
  my ($self, $dir) = @_;
  return if defined $self->{temp_dir};
  $self->{temp_dir} = $dir->child('.tmp')->to_string;
  path($self->{temp_dir})->make_path unless -d $self->{temp_dir};
  $self->logf(debug => 'Temp directory set to %s', $self->{temp_dir});
}

sub _run {
  my ($self, @command) = @_;
  $self->logf(info => '$ %s', join ' ', map { /\s/ ? qq('$_') : $_ } @command);
  return 0 if $self->dry_run;

  local ($?, $!);
  system @command;
  return int($? || $! || 0);
}

sub _tmp {
  my ($self, @args) = @_;
  return tempfile(@args, DIR => $self->{temp_dir} || File::Spec->tmpdir);
}

app {
  my ($self, $file) = @_;
  die "Usage: $0 <file>\n" unless $file;

  $self->{temp_dir} = $ENV{DVDB_TEMP_DIR};

  return $self->convert($file)     if $file =~ m!\.iso$!i;
  return $self->convert_all($file) if -d $file;
  return $self->clone($file)       if -b $file;

  die "Input file ($file) must be an .iso, directory with iso files or a block device.\n";
};
