#!/usr/bin/perl

=head1 NAME

copy.pl - cp, but with status printed while copying

=head1 SYNOPSIS

 $ copy.pl srcfile.1 srcfile.2 destination/folder;
 $ copy.pl srcfile.1 dstfile.1;

=head1 INSTALL DEPENDENCIES

 cpan -i Term::ReadKey;

=cut

use strict;
use warnings;
use sigtrap 'handler' => \&signalled, 'normal-signals';
use File::Basename;
use Term::ReadKey;
use Time::HiRes qw/gettimeofday tv_interval/;

our $VERSION = 0.01;

my $COLS         = (GetTerminalSize())[0];
my $BUFFER       = $ENV{'COPY_BUFFER'} || 2048;
my $PROGBAR_SIZE = $COLS - 40;
my $LINE         = "\r %-" .($COLS - 2) .'s';
my $CURRENT_FILE;
my $ALARM_SET;
my $t0;

exit(@ARGV ? run(@ARGV) : help());

=head1 FUNCTIONS

=head2 run

 $exit_value = run(@files, $destination);

Will copy files files to destination.

=cut

sub run {
    my $destination = pop;
    my @files       = @_;

    if(@files > 1 and !-d $destination) {
        die "Cannot copy more than one file, "
           ."unless destination is a directory\n";
    }

    $|++;

    FILE:
    for my $file (@files) {
        unless(-f $file) {
            warn "! File ($file) is not a plain file\n";
            next FILE;
        }
 
        if(-d $file) {
            directory_copy($file, $destination);
            next FILE;
        }

        copy_file($file, $destination);
    }

    return 0;
}

=head2 directory_copy

 $bool = directory_copy($from_dir, $to_dir); 

Will loop all files in a directory and copy the files inside, using L<run()>.

=cut

sub directory_copy {
    my $from_dir = shift;
    my $to_dir   = shift;
    my(@files, $destination);

    opendir(my $DH, $from_dir);

    @files       = map { "$from_dir/$_" } grep { !/^\.{1,2}$/ } readdir $DH;
    $destination = "$to_dir/" .basename($from_dir);

    closedir $DH;

    if(-d $destination and -w _) {
        return !run(@files, $destination);
    }
    elsif(mkdir $destination) {
        return !run(@files, $destination);
    }

    warn "! Could not write destination directory: $!\n";
    return;
}

=head2 copy_file

 $bool = copy_file($source, $destination);

Will copy one file from one location to another.

=cut

sub copy_file {
    my $source      = shift;
    my $destination = shift;
    my $source_size = (stat $source)[7] || 0;
    my $data_copied = 0;
    my($SRC, $DST, $chunk);

    $t0 = [ gettimeofday ]; # global

    if(-d $destination) {
        $destination = join "/", $destination, basename($source) 
    }

    $destination =~ s,/+,/,g;

    if(-e $destination) {
        $data_copied = (stat $destination)[7];
        if($source_size == $data_copied) {
            warn "> File $source has the same size as destination\n";
            return 0;
        }
        elsif($data_copied) {
            #print "? $destination exists, but contains less data than $source.\n";
            #print "  Do you want to resume/overwrite/skip? (r/o/s) ";
            #my $answer    = <STDIN>;
            #$data_copied  = 0 unless($answer =~ /^r/i);
            #return 0              if($answer =~ /^s/i);
        }
    }

    unless(open($SRC,  '<', $source))  {
        warn "! Could not read file: $!\n";
        return 255;
    }
    unless(open($DST, '>', $destination)) {
        warn "! Could not write file: $!\n";
        return 254;
    }

    binmode $SRC;
    binmode $DST;
    sysseek $SRC, $data_copied, 0;
    sysseek $DST, $data_copied, 0;
    print "Copying $source to $destination\n"; 

    $CURRENT_FILE = $destination;
    
    while(my $read = sysread $SRC, $chunk, $BUFFER) {

        my $written   = syswrite($DST, $chunk);
        $data_copied += $written;

        if(!$written or $written != $read) {
            die "\n! IO error: $!\n";
        }

        unless($ALARM_SET++) {
            $SIG{'ALRM'}  = sub { copy_status($source_size, $data_copied) };
            alarm 1;
        }
   }

    alarm 0;

    $CURRENT_FILE = 0;
    $ALARM_SET    = 0;

    print "\n";
    close $SRC;
    close $DST;

    return 1;
}

=head2 copy_status

 copy_status($size, $copied);

Display a progress bar.

=cut

sub copy_status {
    my $size         = shift;
    my $data_copied  = shift;
    my $progress_pos = int($data_copied / $size * $PROGBAR_SIZE);
    my $size_print   = human_number($size),
    my $Bps          = $data_copied / tv_interval($t0);
   
    printf $LINE, sprintf("|%s>%s|%s|%s|%sBps|%is",
        '=' x (                $progress_pos),
        ' ' x ($PROGBAR_SIZE - $progress_pos),
        human_number($data_copied),
        $size_print,
        human_number($Bps),
        ($size - $data_copied) / $Bps,
    );
 
    $ALARM_SET = 0;
}

=head2 human_number

 $str = human_number($int);

Takes an int, and turns it into a human-readable number.

=cut

sub human_number {
    my $number = shift || 0;
    my $format = "%.1f%s";
    my %suffix = (
                     12  => 'T',
                     9   => 'G',
                     6   => 'M',
                     3   => 'k',
                     0   => ' ',
                 );

    for my $exp (sort { $b <=> $a } keys %suffix) {
        if($number >= 10 ** $exp) {
            $number /= 10 ** $exp;
            $number  = sprintf $format, $number, $suffix{$exp};
            last;
        }
    }

    return($number || sprintf $format, 0, $suffix{0});
}

=head2 signalled

Will be called when a *normal* signal is received.

=cut

sub signalled {
    print "\n";
    alarm 0;

    if($CURRENT_FILE) {
        print STDERR "\n# Aborted copy of '$CURRENT_FILE'\n";
        print STDERR "# Do you want to delete the destination file? (y/N) ";

        my $answer = <STDIN>;

        if($answer =~ /^y/i) {
            unlink $CURRENT_FILE;
        }
    }

    exit 0;
}

=head2 help

 help()

Display usage.

=cut

sub help {
    print <<'USAGE';
Usage:
 $ copy.pl src-file-1 src-file-2 destination/folder;
 $ copy.pl src-file dest-file

USAGE

    return 0;
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen - jhthorsen -at- cpan.org

=cut
