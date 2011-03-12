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
use Carp;
use Cwd;
use Data::Dumper ();
use File::Path qw/ make_path /;
use Net::IMAP::Simple;
use MIME::Base64 ();
use base 'Class::Accessor::Fast::WithBuilder';

our $AUTOLOAD; # TODO: define fixed proxy methods instead
our $MAIL_MAP = '.mail_map';

__PACKAGE__->mk_accessors(qw(
    _client
    maildir
    port
    server
    ssl
    username
    password
    timeout
    trash_mailbox
    _mail_map
));

sub _build_port { 993 }
sub _build_maildir { 'Maildir' }
sub _build_trash_mailbox { 'Trash' }
sub _build_timeout { 10 }
sub _build_server { 'localhost' }
sub _build_ssl { shift->port eq '993' ? 1 : 0 }
sub _build_username { shift->throw_exception('Usage: $self->new({ username => $Str, ... })') }
sub _build_password { shift->throw_exception('Usage: $self->new({ password => $Str, ... })') }

sub _build__mail_map {
    my $self = shift;
    open my $MAP_FH, '<', $self->maildir .'/' .$MAIL_MAP or return {};
    local $/; # slurp
    my $mail_map = eval(readline $MAP_FH) or $self->throw_exception($@);
    return $mail_map;
}

sub track_file { $_[0]->_mail_map->{'file_to_timestamp'}{$_[1]} = $_[2] }
sub tracked_files { keys %{ $_[0]->_mail_map->{'file_to_timestamp'} } }
sub tracked_file { $_[0]->_mail_map->{'file_to_timestamp'}{$_[1]} || 0 }

sub untrack_file {
    my($self, $file) = @_;
    my $uid = delete $self->_mail_map->{'file_to_uid'}{$file};

    delete $self->_mail_map->{'file_to_timestamp'}{$file};
    delete $self->_mail_map->{'uid_to_file'}{$uid} if($uid);
}

sub uid_to_file {
    my $self = shift;
    my $uid = shift;

    if(@_) {
        $self->_mail_map->{'uid_to_file'}{$uid} = $_[0];
        $self->_mail_map->{'file_to_uid'}{$_[0]} = $uid;
    }

    return $self->_mail_map->{'uid_to_file'}{$uid};
}

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
    my $time = time;
    my $old_dir = cwd or $self->throw_exception('Failed to get current directory');

    print "Syncing ", $self->maildir, " ...\n";
    chdir $self->maildir or $self->throw_exception('Maildir does not exist:', $self->maildir);

    MAILBOX:
    for my $box ($self->mailboxes) {
        unless(-d $box) {
            print "> make_path '$box'\n";
            make_path $box;
        }

        $self->sync_messages($box, $time);
        $self->expunge_mailbox($box);
    }

    FILE:
    for my $file ($self->tracked_files) {
        if($self->tracked_file($file) < $time) {
            print "> deleted on server: $file\n";
            unlink $file;
            $self->untrack_file($file);
        }
    }

    chdir $old_dir;
    return $self->write_mail_map;
}

# need to be called after chdir
sub sync_messages {
    my($self, $box, $time) = @_;
    my $trash_mailbox = $self->trash_mailbox;
    my $n_messages = $self->select($box) or return 0;

    MESSAGE:
    for my $message_number (1..$n_messages) {
        my($uid) = $self->uid($message_number) or next MESSAGE;
        my $source = $self->uid_to_file($uid);
        my $file = "$box/$uid";

        if(-e $file) {
            $self->track_file($file, $time);
            $self->uid_to_file($uid, $file);
        }
        elsif($self->tracked_file($file)) {
            if($trash_mailbox eq $box) {
                printf "> expunge from %s: %s\n", $box, $file;
            }
            else {
                printf "> move to %s: %s\n", $trash_mailbox, $file;
                $self->copy($message_number, $trash_mailbox) or $self->throw_exception;
            }
            $self->delete($message_number) or $self->throw_exception;
            $self->untrack_file($file);
        }
        elsif($source and -r $source and $source eq $file) {
            $source =~ s/^\.\.\///;
            print "> link $source => $file\n";
            link $source => $file or $self->throw_exception("link '$source' => '$file' failed: $!");
        }
        else {
            print "> download $file\n";
            my $IMAP_MAIL = $self->getfh($message_number) or $self->throw_exception;
            open my $LOCAL_MAIL, '>', $file or $self->throw_exception("Write $file: $!");
            print $LOCAL_MAIL $_ while(<$IMAP_MAIL>);
            $self->track_file($file, $time);
            $self->uid_to_file($uid, $file);
        }
    }

    return $n_messages;
}

sub write_mail_map {
    my $self = shift;
    open my $MAP_FH, '>', $self->maildir ."/$MAIL_MAP";
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Purity = 1;
    print $MAP_FH Data::Dumper::Dumper($self->_mail_map);
}

sub throw_exception {
    my($self, @msg) = @_;
    @msg = ($self->errstr) unless(@msg);
    s/[\r\n]//g for(@msg);
    Carp::confess(join ' ', @msg);
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

    # dump information
    \$ $0 --config /path/to/config.ini dump;

    # sync with local mailbox:
    \$ $0 --config /path/to/config.ini sync;

USAGE
    return 0;
}

exit __PACKAGE__->new_with_options->run unless($ENV{'NO_SYNCAPP_RUN'});
