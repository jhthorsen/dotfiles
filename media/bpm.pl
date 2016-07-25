#!/usr/bin/env perl
use Applify;

use Image::ExifTool;
use File::Basename 'dirname';
use Mojo::Util qw(md5_sum slurp);

option str => dff   => 'Date from filename';
option str => drive => 'Path to google drive',
  $ENV{GOOGLE_DRIVE_DIR} || "/Users/$ENV{USER}/Google/Photos";
option str => source => 'Where imported files are',
  $ENV{GOOGLE_PHOTOS_IMPORT_SOURCE} || "/Users/$ENV{USER}/Downloads/import";
option bool => dry_run => 'Do not delete files';

documentation __FILE__;

my $NUM_RE    = '(\d+)\D*';
my $TS_FORMAT = '%04s-%02s-%02s-%02s%02s%02s';

sub checksums_for {
  my ($self, $year, $key) = @_;
  return $self->{checksum}{$year}{$key} if $self->{checksum}{$year}{$key};

  opendir(my $DH, File::Spec->catdir($self->drive, $year)) or return {};
  my $checksum = $self->{checksum}{$year}{$key} = {};
  while (my $f = readdir $DH) {
    next unless $f =~ /^\d+-$key/;    # do not want to calculate md5_sum for every file
    my $path = File::Spec->catdir($self->drive, $year, $f);
    my $md5 = md5_sum slurp $path;
    $checksum->{$md5} = $path;
  }

  return $checksum;
}

sub delete_duplicate {
  my ($self, $file, $slug, $checksum) = @_;
  my ($year, $key) = $slug =~ /^(\d+)-(\d+-\d+)/ or die "No year in slug?? ($slug)";

  for (0 .. 1) {
    if ($self->checksums_for($year, $key)->{$checksum}) {
      warn "rm $file\n";
      unlink $file or die "rm $file: $!" unless $self->dry_run;
      return 1;
    }
    $year--;  # check last year, since sometimes 2014-01-01-00000 gets stored in year 2013
  }

  return 0;
}

sub file_slug {
  my ($self, $file) = @_;
  my ($ext) = $file =~ /\.(\w+)?$/ or return;
  my $exif = Image::ExifTool->new;
  my %ts;

  unless ($ext =~ qr{^(jpe?g|png|mov|mp4)$}i) {
    warn qq(Unknown extension for "$file".\n);
    return;
  }
  if (!$self->dff and !$exif->ExtractInfo($file)) {
    warn qq(Unable to extract Exif data from "$file".\n);
    return;
  }
  if ($self->dff) {
    $file =~ m!(\d{4})-(\d+)-(\d+)-(\d\d)(\d\d)(\d\d)!x or return;
    $ts{date} ||= sprintf $TS_FORMAT, $1, $2, $3, $4, $5, $6;
  }

  for my $k (qw(CreateDate DateTimeOriginal ModifyDate GPSDateTime)) {
    $ts{$k} = $exif->GetValue($k) || '';
    $ts{$k} =~ m!(\d{4}) [:-]+ $NUM_RE $NUM_RE $NUM_RE $NUM_RE $NUM_RE!x or next;

    if ($2 > 12) {
      $ts{date} ||= sprintf $TS_FORMAT, $1, $3, $2, $4, $5, $6;
      $ts{$k} = '';    # make sure we overwrite invalid date
    }
    else {
      $ts{date} ||= sprintf $TS_FORMAT, $1, $2, $3, $4, $5, $6;
    }
  }

  unless ($ts{date}) {
    my @ts = localtime +(stat $file)[9];
    $ts{date} = sprintf $TS_FORMAT, $ts[5] + 1900, $ts[4] + 1, @ts[3, 2, 1, 0];
  }
  unless ($self->dry_run) {
    $exif->SetNewValue($_ => $ts{date}) for grep { !$ts{$_} } keys %ts;
    $exif->WriteInfo($file) if grep { !$ts{$_} } keys %ts;
  }

  my $md5 = md5_sum slurp $file;
  return sprintf('%s_%s.%s', $ts{date}, substr($md5, 0, 3), lc $ext), $md5;
}

app {
  my ($self) = @_;
  my $filter = $self->dff || '.';

  opendir my $DH, $self->source or die $!;
  my @files = sort map { File::Spec->catfile($self->source, $_) } readdir $DH;
  my ($checksum, $file, $slug);

  while ($file = shift @files) {
    next unless $file =~ /$filter/;
    next if -d $file;
    ($slug, $checksum) = $self->file_slug($file) or next;
    my $target = File::Spec->catfile($self->source, $slug);
    $self->delete_duplicate($file, $slug, $checksum) and next;
    warn "mv $file $target\n" unless -e $target;
    rename $file => $target
      or die "mv $file $target: $!"
      if !-e $target and !$self->dry_run;
  }

  return 0;
};

=head1 NAME

bpm.pl - Batman's picture manager

=head1 SYNOPSIS

  $ bpm.pl

=head1 DESCRIPTION

This script is used to rename files imported from cameras. The filenames will
contain the actual date, instead of being named something like DSC_2254.jpg

This script will also delete any files that are already uploaded to to Google
drive and synced back to the local computer.

=head1 AUTHOR

Jan Henning Thorsen

=cut
