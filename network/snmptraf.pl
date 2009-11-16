#!/usr/bin/perl

=head1 NAME

snmptraf.pl

=head1 SYNOPSIS 

 snmptraf [-l|-v|-d|-t <float>|-m] <modem1> <modem2> ... <modem10>

  -l|--long     use 64 bit counters
  -v|--verbose  more information
  -d|--debug    debug info
  -t|--timeout  how long to wait for an answer
  -m|--modem    get information from a cable modem
 
=head2 Example

 snmptraf 10.0.0.3 10.30.2.6 10.34.6.100

=head1 INSTALL DEPENDENCIES

 cpan -i Getopt::Long;
 cpan -i SNMP::Effective;

=cut

use strict;
use warnings;
use Getopt::Long;
use SNMP::Effective;
use Time::HiRes qw/gettimeofday tv_interval usleep/;

my $VERBOSE  = 0;
my $DEBUG    = 0;
my $USE64    = 0;
my $INTERVAL = 0.5;

GetOptions(
    qw'  verbose|v ' => \$VERBOSE,
    qw'    debug|d ' => \$DEBUG,
    qw'     long|l ' => \$USE64,
    qw'  timeout|t ' => \$INTERVAL,
);

my @HOSTS       = @ARGV;
my $ifDescr_oid = '1.3.6.1.2.1.2.2.1.2';
my $ifType_oid  = '1.3.6.1.2.1.2.2.1.3';
my %getnext     = $USE64 ? (
                      '1.3.6.1.2.1.31.1.1.1.6'  => 'in',
                      '1.3.6.1.2.1.31.1.1.1.10' => 'out',
                      $ifDescr_oid              => '',
                      $ifType_oid               => '',
                  ) :
                  (
                      '1.3.6.1.2.1.2.2.1.10' => 'in',
                      '1.3.6.1.2.1.2.2.1.16' => 'out',
                      $ifDescr_oid           => '',
                      $ifType_oid            => '',
                  );
my %old_data;
$|++;


unless(@HOSTS) {
    print <<"USAGE";
 USAGE:
 snmptraf [-l|-v|-d|-t <float>|-m] <modem1> <modem2> ... <modem10>

  -l|--long     use 64 bit counters
  -v|--verbose  more information
  -d|--debug    debug info
  -t|--timeout  how long to wait for an answer
  -m|--modem    get information from a cable modem
 
 EXAMPLE:
 snmptraf 10.0.0.3 10.30.2.6 10.34.6.100
USAGE
 exit 255;
}

while(1) {
    my $t0 = [gettimeofday];
    my $snmp = SNMP::Effective->new(
                   max_sessions => 10,
                   master_timeout => 1,
                   callback => \&calculate,
                   dest_host => \@HOSTS,
                   walk => [ keys %getnext ],
               );

    $snmp->execute;

    if(tv_interval($t0) > $INTERVAL) {
        warn "Interval Overflow!\n\n";
        %old_data = ();
        next;
    }

    usleep 1e3 while(tv_interval($t0) < $INTERVAL);
}

=head1 FUNCTIONS

=head2 calculate

 calculate($host_obj, $error);

Callback for L<SNMP::Effective>. Will calculate the data run through the
device, and print the result to STDOUT.

=cut

sub calculate {
    my $host = shift;
    my $error = shift;
    my $data = $host->data;
    my %new_data = ( total => { in => 0, out => 0 } );
    my %com_data = $old_data{"$host"} ? %{ $old_data{"$host"} } : ();
    my $amp = 8 / $INTERVAL;

    debug("Calculating data from $host");

    if($error) {
        warn "$host : $error";
        return;
    }

    SNMP_DATA:
    for my $oid (keys %$data) {
        my $oid_name = $getnext{$oid} or next SNMP_DATA;

        IID:
        for my $iid (keys %{$data->{$oid}}) {

            my $ifType =  $data->{$ifType_oid}{$iid} or  next IID;
               $ifType =~ /(24|12[789]|205)/         and next IID;

            $new_data{'total'}{$oid_name} += $data->{$oid}{$iid} || 0;
            $new_data{$iid}{$oid_name}     = $data->{$oid}{$iid} || 0;
            $new_data{$iid}{'name'}        = $data->{$ifDescr_oid}{$iid} || '';

            debug(sprintf "%14s-%5s/%-5s-%s",
                $host,
                $oid_name,
                $ifType,
                $data->{$oid}{$iid}
            );
        }
    }

    for my $k (sort keys %com_data) {
        next unless($k eq 'total' or $VERBOSE);

        my $new = $new_data{$k};
        my $com = $com_data{$k};
        my $diff_in  = ($new->{'in'} >= $com->{'in'})
                     ?              $new->{'in'} - $com->{'in'}
                     : 0xffffffff - $new->{'in'} + $com->{'in'};
        my $diff_out = ($new->{'out'} >= $com->{'out'})
                     ?              $new->{'out'} - $com->{'out'}
                     : 0xffffffff - $new->{'out'} + $com->{'out'};
        my $in = human_number($diff_in  * $amp);
        my $out = human_number($diff_out * $amp);
        my $descr = ($k eq 'total') ? "$host" : $new->{'name'};

        next unless($diff_in || $diff_out);

        printf "%-14s In %8s       Out %8s  bps\n", $descr, $in, $out;
    }

    print "-" x 50, "\n" if($VERBOSE);

    $old_data{"$host"} = \%new_data;
}

=head2 debug

 debug($msg);

Prints C<$msg> to STDERR if C<$DEBUG> is set.

=cut

sub debug {
    return unless($DEBUG);
    print "$_[0]\n";
}

=head2 human_number

 $str = human_number($int);

Returns a human readable number, with k, M or G suffix.

=cut

sub human_number {
    my $number = shift || 0;
    my $decimals = shift || 1;
    my $format = shift || "%.${decimals}f%s";
    my %suffix = (
                      12 => 'T',
                      9  => 'G',
                      6  => 'M',
                      3  => 'k',
                      0  => '',
                     -3  => 'm',
                     -6  => 'u',
                     -9  => 'p',
                     -12 => 'n',
                 );
    
    for my $exp (sort { $b <=> $a } keys %suffix) {
        if($number >= 10 ** $exp) {
            $number /= 10 ** $exp;
            $number  = sprintf $format, $number, $suffix{$exp};
            last;
        }
    }

    return($number || sprintf $format, 0, "");
}

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen jhthorsen -at- cpan.org

=cut
