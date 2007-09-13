#!/usr/bin/perl

#===========
# forward.pl
#===========

use strict;
use IO::Socket::INET;
use vars qw/$ENABLED @VALID_PEERS $LOCAL_PORT $PEER_ADDR $PEER_PORT/;


#== USER SETTINGS ============================================================
$ENABLED     = 1;
$LOCAL_PORT  = shift @ARGV or usage();
$PEER_ADDR   = shift @ARGV or usage();
$PEER_PORT   = shift @ARGV or usage();
@VALID_PEERS = @ARGV;
#=============================================================================

my $server = IO::Socket::INET->new(
                 LocalPort => $LOCAL_PORT,
                 Proto     => 'tcp',
                 Listen    => 5,
                 Timeout   => 5,
             ) or die "Could not create socket: $!\n";
$|++;

print "Port forwarding has started:\n";
print "From port $LOCAL_PORT to $PEER_ADDR\:$PEER_PORT\n";
print "Valid peers: @VALID_PEERS\n";

LISTEN:
while(1) {

    ### init
    my $client = $server->accept or next LISTEN;

    ### debug
    print "Checking peer host: " .$client->peerhost() ."... ";

    ### check peer
    grep { $_ eq $client->peerhost } @VALID_PEERS or next LISTEN;
    print "OK";

    ### connect to printer
    my $printer = IO::Socket::INET->new(
                      PeerAddr => $PEER_ADDR,
                      PeerPort => $PEER_PORT,
                  ) or die "Could not connect to printer: $!\n";

    ### print
    if($ENABLED) {
        print $printer $_ while(<$client>);
    }
    else {
        print "." while(<$client>);
    }
}

### THE END
exit 0;


sub usage { #=================================================================

    print <<'USAGE';
Usage:
 $ forward.pl <LISTEN_PORT> <PEER_ADDR> <PEER_PORT> <ALLOW_CLIENTS>

USAGE

    exit 255;
}
