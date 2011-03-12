#!/usr/bin/perl
use strict;
use warnings;

BEGIN {
    for my $mod (qw(
        Class::Accessor::Fast::WithBuilder
        Config::Tiny
        Net::IMAP::Simple
    )) {
        eval "require $mod; 1" or die "Required module need to be installed: $mod\n";
    }
}

#=============================================================================
package App::SyncIMAP::Client;
use Carp qw/confess/;
use File::Path qw/ make_path /;
use Net::IMAP::Simple;
use MIME::Base64 ();
use base 'Class::Accessor::Fast::WithBuilder';

our $AUTOLOAD; # TODO: define fixed proxy methods instead

__PACKAGE__->mk_accessors(qw(
    _client
    maildir
    port
    server
    ssl
    username
    password
    timeout
    uid_to_path
));

sub _build_port { 993 }
sub _build_maildir { 'Maildir' }
sub _build_timeout { 10 }
sub _build_server { 'localhost' }
sub _build_ssl { shift->port eq '993' ? 1 : 0 }
sub _build_username { confess 'Usage: $self->new({ username => $Str, ... })' }
sub _build_password { confess 'Usage: $self->new({ password => $Str, ... })' }
sub _build_uid_to_path { +{} }

sub _build__client {
    my $self = shift;

    return Net::IMAP::Simple->new(
        join(':', $self->server, $self->port),
        timeout => $self->timeout,
        use_ssl => $self->ssl,
        retry => 1,
        retry_delay => 5,
        use_v6 => 0,
        debug => $ENV{'SYNCAPP_DEBUG'} ? 'warn' : undef,
        #use_select_cache => 1,
        #select_cache_ttl => 60,
    );
}

sub login {
    return $_[0]->_client->login(
        $_[0]->username,
        MIME::Base64::decode_base64($_[0]->password),
    );
}

sub dump {
    my $self = shift;

    for my $method (qw/ uidnext examine flags current_box /) {
        printf "%s: %s\n", $method, join ',', $self->$method;
    }

    for my $box ($self->mailboxes) {
        printf "mailbox: /%s\n", $box;
    }
    #for my $box ($self->mailboxes_subscribed) {
    #    printf "mailbox subscribed: /%s\n", $box;
    #}

    return 1;
}

sub sync {
    my $self = shift;
    my $uid_to_path = $self->uid_to_path;

    MAILBOX:
    for my $box ($self->mailboxes) {
        my $n_messages = $self->examine($box) or next;
        my $maildir = join '/', $self->maildir, $box;

        unless(-d $maildir) {
            print "make_path '$maildir'\n";
            make_path $maildir;
        }

        MESSAGE:
        for my $message_number (1..$n_messages) {
            my($uid) = $self->uid($message_number) or next;
            my $file = "$maildir/$uid";

            if(-e $file) {
                print "$file exists\n";
                $uid_to_path->{$uid} = $file;
            }
            elsif(my $source = $uid_to_path->{$uid}) {
                print "symlink $source => $file\n";
                symlink $source => $file or confess "symlink $source => $file failed: $!";
            }
            else {
                print "cp $box/$uid => $file\n";
                my $IMAP_MAIL = $self->getfh($message_number) or confess $self->errstr;
                open my $LOCAL_MAIL, '>', $file or confess "Write $file: $!";
                while(<$IMAP_MAIL>) {
                    print $LOCAL_MAIL $_;
                }
                $uid_to_path->{$uid} = $file;
            }
        }

        #warn $self->create_mailbox("/foo/bar");
        #warn $self->expunge_mailbox("/foo/bar");
    }

    $self->close;
    $self->logout;

    return 1;
}

sub new {
    my $self = shift->SUPER::new(@_);

    # need to have a value
    $self->_build_username unless($self->username);
    $self->_build_password unless($self->password);
    
    return $self;
}

sub AUTOLOAD {
    my $method = ($AUTOLOAD =~ /::(\w+)$/)[0];
    return if($method eq 'DESTROY');
    return shift->_client->$method(@_) if($_[0]->_client->can($method));
    confess "Cannot proxy method $method to Net::IMAP::Simple";
}

#=============================================================================
package App::SyncIMAP;
use Carp qw/confess/;
use Config::Tiny;
use MIME::Base64 ();
use base 'Class::Accessor::Fast::WithBuilder';

__PACKAGE__->mk_accessors(qw( config extra_argv _clients ));
sub clients { @{ $_[0]->_clients } }

sub _build_config { confess 'Usage: $self->new({ config => path/to/config, ... })' }
sub _build_extra_argv { [] }
sub _build__clients {
    my $self = shift;
    my $config = Config::Tiny->new->read($self->config) or confess(Config::Tiny->errstr);
    my @clients;

    for my $section (keys %$config) {
        next if($section eq '_');
        $config->{$section}{'maildir'} ||= $section;
        push @clients, App::SyncIMAP::Client->new($config->{$section});
    }

    return \@clients;
}

sub run {
    my $self = shift;
    my $action = $self->extra_argv->[0] || 'sync';

    if(0 == grep { $action eq $_ } qw/ encode dump sync /) {
        exit $self->print_usage;
    }

    if($action eq 'encode') {
        print "Enter password: ";
        my $input = <STDIN>;
        chomp $input;
        print "BASE64 encoded: ", MIME::Base64::encode_base64($input), "\n";
        return 0;
    }

    if($self->clients == 0) {
        die "No clients defined in config file ", $self->config, "\n";
    }

    for my $client ($self->clients) {
        $client->login or die "Could not login to ", $client->server, "\n";
        $action eq 'dump' ? $client->dump : $client->sync;
        $client->logout;
        $client->close;
    }

    return 0;
}

sub new_with_options {
    my $class = shift;
    my @args = @_;
    my(%args, @extra);

    while(@ARGV) {
        my $arg = shift @ARGV;
        if($arg =~ s/^--//) {
            $arg =~ s/-/_/g;
            $args{$arg} = (@ARGV and $ARGV[0] !~ /^--/) ? shift(@ARGV) : 1;
        }
        else {
            push @extra, $arg;
        }
    }

    if(!$args{'config'}) {
        $args{'config'} = (@extra and -e $extra[0]) ? shift @extra : '/dev/null';
    }
    if(grep { $args{$_} } qw/ h help ? /) {
        exit $class->print_usage;
    }

    return $class->new({ @args, %args, extra_argv => \@extra });
}

sub print_usage {
    print <<"USAGE";

    # encode a password for config file:
    \$ $0 encode;

    # list mailboxes
    \$ $0 --config /path/to/config.ini dump;

    # sync to local mailbox:
    \$ $0 --config /path/to/config.ini sync;

USAGE
    return 0;
}

exit __PACKAGE__->new_with_options->run unless($ENV{'NO_SYNCAPP_RUN'});
