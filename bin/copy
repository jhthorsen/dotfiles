#!/usr/bin/perl

#=====
# copy
#=====

use strict;
use warnings;
use File::Basename;
use sigtrap 'handler' => \&end, 'normal-signals';
use Term::ReadKey;
use Time::HiRes qw/gettimeofday tv_interval/;


### CHECK ARGS
if(@ARGV > 2 and !-d $ARGV[-1]) {
    die "Cannot copy more than one file, unless destination is a directory\n";
}

### INIT PROGRAM
my $COLS         = (GetTerminalSize())[0];
my $BUFFER       = 2048;
my $PROGBAR_SIZE = $COLS - 40;
my $LINE         = "\r %-" .($COLS - 2) .'s';
my $CURRENT_FILE;
my $ALARM_SET;
my $t0;
$|++;

### COPY FILE
loop_files(@ARGV);

### THE END
exit 0;


sub loop_files { #============================================================

    ### init
    my $dst = pop;

    SRC:
    for my $src (@_) {

        ### dig deeper into the rabit hole
        if(-d $src) {

            ### read directory
            opendir(DIR, $src);
            my @files  = map { "$src/$_" } grep { !/^\.{1,2}$/ } readdir DIR;
            my $dst    = "$dst/" .(split m{/}, $src)[-1];
            closedir DIR;

            if(-d $dst and -w _) {
                loop_files(@files, $dst);
            }
            elsif(mkdir $dst) {
                loop_files(@files, $dst);
            }
            else {
                warn "! Could not write destination directory: $!\n";
            }

            ### next file
            next SRC;
        }

        ### other kind of file
        unless(-f $src) {
            warn "! File ($src) is not a plain file\n";
            next SRC;
        }
    
        ### copy file
        copy_file($src, $dst);
    }
}

sub copy_file { #=============================================================
    
    ### init
    my $src            = shift;
    my $dst            = shift;
    my $data_copied    = 0;
    my $src_size       = (stat $src)[7] || 0;
    my $chunk;
       $t0             = [ gettimeofday ];

    ### fix destination
    $dst =  join "/", $dst, basename($src) if(-d $dst);
    $dst =~ s/\/{2}/\//g;

    ### check src and dst file size
    if(-e $dst) {
        $data_copied = (stat $dst)[7];
        if($src_size == $data_copied) {
            warn "> File $src has the same size as destination\n";
            return 0;
        }
        elsif($data_copied) {
            #print "? $dst exists, but contains less data than $src.\n";
            #print "  Do you want to resume/overwrite/skip? (r/o/s) ";
            #my $answer    = <STDIN>;
            #$data_copied  = 0 unless($answer =~ /^r/i);
            #return 0              if($answer =~ /^s/i);
        }
    }

    ### open files
    unless(open(SRC,  '<', $src))  {
        warn "! Could not read file: $!\n";
        return 255;
    }
    unless(open(DST, '>', $dst)) {
        warn "! Could not write file: $!\n";
        return 254;
    }

    ### init copy
    binmode SRC;
    binmode DST;
    sysseek SRC, $data_copied, 0;
    sysseek DST, $data_copied, 0;
    print "Copying $src to $dst\n"; 
    $CURRENT_FILE = $dst;
    
    READ:
    while(my $read = sysread SRC, $chunk, $BUFFER) {

        my $written   = syswrite(DST, $chunk);
        $data_copied += $written;

        if(!$written or $written != $read) {
            die "\n! IO error: $!\n";
        }


        unless($ALARM_SET++) {
            $SIG{'ALRM'}  = sub { copy_status($src_size, $data_copied) };
            alarm 1;
        }
   }

    ### loop end
    alarm 0;
    $CURRENT_FILE = 0;
    $ALARM_SET    = 0;
    print "\n";
    close SRC;
    close DST;
}

sub copy_status { #===========================================================

    ### init
    my $src_size       = shift;
    my $data_copied    = shift;
    my $progress_pos   = int($data_copied / $src_size * $PROGBAR_SIZE);
    my $src_size_print = human_number($src_size),
    my $Bps            = $data_copied / tv_interval($t0);
   
    ### print status
    printf $LINE, sprintf("|%s>%s|%s|%s|%sBps|%is",
        '=' x (                $progress_pos),
        ' ' x ($PROGBAR_SIZE - $progress_pos),
        human_number($data_copied),
        $src_size_print,
        human_number($Bps),
        ($src_size - $data_copied) / $Bps,
    );
 
    ### the end
    $ALARM_SET = 0;
}

sub human_number { #==========================================================
    
    ### init
    my $number = shift || 0;
    my $format = "%.1f%s";
    my %suffix = (
                     12  => 'T',
                     9   => 'G',
                     6   => 'M',
                     3   => 'k',
                     0   => ' ',
                 );

    ### fix number
    for my $exp (sort { $b <=> $a } keys %suffix) {
        if($number >= 10 ** $exp) {
            $number /= 10 ** $exp;
            $number  = sprintf $format, $number, $suffix{$exp};
            last;
        }
    }

    ### the end
    return($number || sprintf $format, 0, $suffix{0});
}

sub end { #===================================================================

    ### init
    print "\n";
    alarm 0;

    ### unlink file
    if($CURRENT_FILE) {
        print STDERR "\n? Didn't complete copy of $CURRENT_FILE !\n";
        print STDERR "  Do you want to delete the file? (y/N) ";

        my $answer = <STDIN>;

        if($answer =~ /^y/i) {
            unlink $CURRENT_FILE;
        }
    }

    ### the end
    exit 0;
}

