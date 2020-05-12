#!/usr/bin/env perl
use Applify;

use Image::ExifTool;
use File::Basename 'dirname';
use Mojo::File 'path';
use Mojo::Util;

Mojo::Util::monkey_patch('Mojo::File', md5_sum => sub { Mojo::Util::md5_sum(shift->slurp) });

option str => dff   => 'Date from filename';
option str => drive => 'Path to google drive',
  $ENV{GOOGLE_DRIVE_DIR} || "/Users/$ENV{USER}/Google/Photos";
option str => source => 'Where imported files are',
  $ENV{GOOGLE_PHOTOS_IMPORT_SOURCE} || "/Users/$ENV{USER}/Downloads/import";
option bool => dry_run => 'Do not delete files';

documentation __FILE__;

my $NUM_RE    = '(\d+)\D*';
my $TS_FORMAT = '%04s-%02s-%02s-%02s%02s%02s';

sub file_slug {
  my ($self, $file) = @_;
  my ($ext) = $file =~ /\.(\w+)?$/ or return;
  my $exif = Image::ExifTool->new;
  my %ts;

  if ($ext =~ qr{^(arw)$}i) {
    my $dest = path(path($file)->dirname, 'raw', path($file)->basename);
    warn "rename $file\n";
    rename $file, $dest or die "mv $file $dest: $!\n";
    return;
  }
  unless ($ext =~ qr{^(heic|jpe?g|gif|png|mov|mp4)$}i) {
    warn qq(Unknown extension for "$file".\n);
    return;
  }
  if (!$self->dff and !$exif->ExtractInfo($file->to_string)) {
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
    $exif->WriteInfo($file->to_string) if grep { !$ts{$_} } keys %ts;
  }

  my $md5 = path($file)->md5_sum;
  return sprintf '%s_%s.%s', $ts{date}, substr($md5, 0, 3), lc $ext;
}

app {
  my ($self) = @_;
  my $filter = $self->dff || '.';

  my $cannot = sub {
    warn "! $_[0]\n";
  };

  my $source = $self->source;
  path($source)->list_tree->each(sub {
    my $file = shift;
    return unless $file =~ m!\.jpe?g$!i;
    return $cannot->($file) unless my $slug = $self->file_slug($file);
    return $cannot->($file) unless my $year = $slug =~ m!(\d{4})! ? $1 : '';

    my $parts = $file->dirname->to_string;
    $parts =~ s!^$source/?!!;
    $parts =~ s!/! - !g;
    $parts =~ s!\d{4}_\d{2}_\d{2}!!; # Remove 2006_08_24

    my $dest = path("/mnt/debra/kanematsu/Photos", $parts, $year, $slug);
    return if -s $dest;
    $dest->dirname->make_path unless -d $dest->dirname;
    warn "> $dest\n";
    die "link $file => $dest: $!" unless link $file => $dest;
  });

  #opendir my $DH, $self->source or die $!;
  #my @source_files = sort map { path($self->source, $_) } readdir $DH;

  #while (my $file = shift @source_files) {
  #  next unless $file =~ /\.jpe?g$/i;
  #  my $exif = Image::ExifTool->new;
  #  $exif->ExtractInfo($file->to_string);
  #  my $info = $exif->GetInfo(qw(Make ImageWidth ImageHeight));
  #  next unless $info->{Make} and $info->{ImageHeight};
  #  next unless $info->{Make} eq 'SONY';
  #  next unless $info->{ImageWidth} eq '1080' or $info->{ImageHeight} eq '1080';
  #  print "rm $file\n";
  #}
  #return 0;

  #while (my $file = shift @source_files) {
  #  next unless $file =~ /$filter/;
  #  next if -d $file;
  #  my $slug = $self->file_slug($file) or next;
  #  my $slug_file = path($self->source, $slug);
  #  my $uploaded = path($self->drive, $slug =~ m!\b(\d{4})-(\d{2})! ? ($1, $2) : (), $slug);

  #  if (-e $uploaded) {
  #    print "rm $file\n";
  #    unlink $file unless $self->dry_run;
  #  }
  #  elsif (!-e $slug_file) {
  #    print "mv $file $slug_file\n";
  #    rename $file => $slug_file or die "mv $file $slug_file: $!" unless $self->dry_run;
  #  }
  #  elsif ($file ne $slug_file) {
  #    warn "rm $file # duplicate of $slug_file\n";
  #  }
  #}

  return 0;
};

=head1 NAME

photo-renamer.pl - Give media files the name of the date they were created

=head1 SYNOPSIS

  $ photo-renamer.pl

=head1 DESCRIPTION

This script is used to rename files imported from cameras. The filenames will
contain the actual date, instead of being named something like DSC_2254.jpg

This script will also delete any files that are already uploaded to to Google
drive and synced back to the local computer.

=head1 AUTHOR

Jan Henning Thorsen

=cut
