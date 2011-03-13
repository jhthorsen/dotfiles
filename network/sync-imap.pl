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
package App::SyncIMAP;

=head1 NAME

App::SyncIMAP - Application class for sync-imap.pl 

=head1 DESCRIPTION

sync-imap.pl is a script to synchronize a remote IMAP folder and a
local Maildir.

This application is an alternative to
L<http://www.linux-france.org/prj/imapsync>,
L<http://home.arcor.de/armin.diehl/imapcopy/imapcopy.html>,
L<http://isync.sourceforge.net/mbsync.html> and probably a bunch
of other handy tools.

When running C<sync-imap.pl>, the configuration file will be used to
construct L</App::SyncIMAP::Client> objects. Example config:

    [Gmail]
    maildir=/home/USERNAME/mail/Gmail
    username=username@gmail.com
    password=BASE64-ENCODED-STRING
    server=imap.gmail.com
    port=993
    trash_mailbox=[Gmail]/Trash

The encoded password can be constructed with this application.

=head2 Todo

There's probably a lot to do, but...

=over 4

=item *

Bugfixing. This application has not been used much, so there's probably
som evil bugs lurking.

=item *

Adding files locally will not get synced back to IMAP. This script
currently regards the IMAP folder as data source. This will/can be
changed in the future.

=back

=head1 SYNOPSIS

    # encode a password for config file:
    sync-imap.pl encode;

    # dump information
    sync-imap.pl --config /path/to/config.ini dump;
    sync-imap.pl /path/to/config.ini dump;

    # sync with local mailbox:
    sync-imap.pl --config /path/to/config.ini sync;
    sync-imap.pl /path/to/config.ini sync;
    sync-imap.pl /path/to/config.ini;

=cut

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
        $client->login or die "Could not log-in to ", $client->server, "\n";
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


#=============================================================================
package App::SyncIMAP::Client;

=head1 NAME

App::SyncIMAP::Client - IMAP client class

=head1 DISCLAIMER

THIS APPLICATION HAS JUST BEEN TESTED BRIEFLY! USE IT AT YOUR OWN RISK!

=head1 ENVIRONMENT

=head2 VERBOSITY_SYNCIMAP

This environment variable will set the verbosity level for this code.
The default is "1", but it can be forced to "0" or "5".

=over 4

=item 0 means silence.

=item 1 means print "useful" information to screen.

=item 5 means print internal debugging.

=back

=cut

use Carp;
use Cwd;
use Data::Dumper ();
use Net::IMAP::Simple;
use MIME::Base64 ();
use constant VERBOSITY => defined $ENV{'VERBOSITY_SYNCIMAP'} ? $ENV{'VERBOSITY_SYNCIMAP'} : 1;
use base 'Class::Accessor::Fast::WithBuilder';

our $AUTOLOAD; # TODO: define fixed proxy methods instead
our $MAIL_MAP = '.mail_map';

=head1 ATTRIBUTES

=head2 maildir

Default "Mail".

=head2 port

Default 993.

=head2 server

Default "localhost". Could be set to "imap.google.com" for Google.

=head2 ssl

Default 1 if L</port> is "993". Can be specified if L</port> is not
the standard "993".

=head2 username

Required input. Plain string with the login username. Must contain
the whole email address for some services, such as Google.

=head2 password

Required input. Should be a L<MIME::Base64> encoded string to make
it a bit harder to read.

=head2 timeout

Default 10. Given in seconds.

=head2 can_delete

Default 0. The client cannot delete or expunge mails on the server.

=head2 trash_mailbox

Default "Trash". Could be set to "[Gmail]/Trash" for Google.

=head2 mailboxes

    $paths_arrayref = $self->mailboxes;

Set which mailboxes to track.

=cut

__PACKAGE__->mk_accessors(qw(
    _client
    maildir
    port
    server
    ssl
    username
    password
    timeout
    can_delete
    trash_mailbox
    mailboxes
    _mail_map
));

sub _build_port { 993 }
sub _build_maildir { 'Mail' }
sub _build_can_delete { 0 }
sub _build_trash_mailbox { 'Trash' }
sub _build_timeout { 10 }
sub _build_server { 'localhost' }
sub _build_ssl { shift->port eq '993' ? 1 : 0 }
sub _build_mailboxes { [ $_[0]->_client->mailboxes ] }
sub _build_username { shift->_throw_exception('Usage: $self->new({ username => $Str, ... })') }
sub _build_password { shift->_throw_exception('Usage: $self->new({ password => $Str, ... })') }

sub _build__mail_map {
    my $self = shift;
    open my $MAP_FH, '<', $self->maildir .'/' .$MAIL_MAP or return {};
    local $/; # slurp
    my $mail_map = eval(readline $MAP_FH) or $self->_throw_exception($@);
    return $mail_map;
}

=head1 METHODS

=head2 track_email

    $basename = $self->track_email($uid, $timestamp);

Will make sure an email as marked as tracked. The basename returned
will have this format:

    $timestamp-$server-UID$uid

NOTE: The C<$timestamp> given as input may not be the same as part of
the C<$basename>.

=cut

sub track_email {
    my($self, $uid, $time) = @_;
    my $current_box = $self->current_box;
    my $basename;

    if(my $old_time = $self->_mail_map->{"$current_box/$uid"}) {
        $basename = $self->_generate_basename($uid, $old_time);
    }
    else {
        $basename = $self->_generate_basename($uid, $time);
        $self->_mail_map->{'remote_to_local'}{"$current_box/$uid"} = $basename;
        $self->_mail_map->{'local_to_remote'}{$basename} = "$current_box/$uid";
    }

    return $basename;
}

sub _generate_basename {
    return join '-', map { my $s = $_; $s =~ s/(\W)/_/g; $s } $_[2], $_[0]->server, "UID" .$_[1];
}

=head2 tracked_emails

    @filenames = $self->tracked_emails;

Returns a list of files relative to L</maildir>.

=cut

sub tracked_emails {
    return sort keys %{ $_[0]->_mail_map->{'local_to_remote' } };
}

=head2 email_is_tracked

    $bool = $self->email_is_tracked("INBOX/$UID");

=cut

sub email_is_tracked {
    return $_[0]->_mail_map->{'remote_to_local'}{$_[1]};
}

=head2 email_exists

    $int = $self->email_exists($basename);
    $int = $self->email_exists($uid, $timestamp);

=cut

sub email_exists {
    my $self = shift;
    my $basename = @_ == 2 ? $self->_generate_basename(@_) : shift;
    my $needle = $basename =~ /^\d+$/ ? qr{-UID$basename$} : qr{^$basename};

    for my $dir (qw/ new cur /) {
        opendir(my $DH, $dir) or next;
        for my $file (readdir $DH) {
            return "$dir/$basename" if($file =~ $needle);
        }
    }

    return '';
}

=head2 untrack_mail

    $self->untrack_mail("INBOX/$UID");
    $self->untrack_mail($basename);
    $self->untrack_mail($uid, $timestamp);

Will remove the tracking of the file in the internal storage.

=cut

sub untrack_mail {
    my $self = shift;
    my $basename = @_ == 2 ? $self->_generate_basename(@_) : shift;
    my $mail_map = $self->_mail_map;
    my $key;

    if($key = delete $self->_mail_map->{'remote_to_local'}{$basename}) {
        return delete $self->_mail_map->{'local_to_remote'}{$key};
    }
    elsif($key = delete $self->_mail_map->{'local_to_remote'}{$basename}) {
        return delete $self->_mail_map->{'remote_to_local'}{$key};
    }

    return 0;
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
        debug => VERBOSITY == 5 ? 'warn' : undef,
        #use_select_cache => 1,
        #select_cache_ttl => 60,
    );
}

=head2 login

Will use L</username> and L</password> to login. Will throw an exception
if it fails.

=cut

sub login {
    my $self = shift;
    my $password = MIME::Base64::decode_base64($self->password);

    unless($self->_client->login($self->username, $password)) {
        $self->_throw_exception;
    }

    return 1;
}

=head2 dump

    ??? = $self->dump;

TBD.

=cut

sub dump {
    my $self = shift;
    my %res;

    for my $method (qw/ uidnext examine flags current_box /) {
        $res{$method} = [$self->$method];
        printf "%s: %s\n", $method, join ',', @{ $res{$method} } if VERBOSITY;
    }

    for my $box ($self->_client->mailboxes) {
        push @{ $res{'mailboxes'} }, $box;
        printf "mailbox: /%s\n", $box if VERBOSITY;
    }
    #for my $box ($self->_client->mailboxes_subscribed) {
    #    printf "mailbox subscribed: /%s\n", $box if VERBOSITY;
    #}

    return \%res;
}

=head2 sync

Will sync the given L</maildir> to/from the given L</server>. It will
create the directories and mails on local disk when seen on the server:

    $maildir/$mailbox/$uid

The C<$mailbox> part may contain more than one level of directories.
The C<$uid> is used to track which files was seen and not. In addition
it will store the UID and file information in

    $maildir/.mail_map

which is a file containg a complex Perl data structure.

This method use L<Net::IMAP::Simple/mailboxes> to retrieve the mailbox
list, L</sync_message> to do the actual syncing and last
L<Net::IMAP::Simple/expunge_mailbox> to expunge any mailes marked for
deletion. After the chatting with the server it will delete all the
L<files|/tracked_emails> on disk which is not on the server.

=cut

sub sync {
    my $self = shift;
    my $time = time;
    my $old_dir = cwd or $self->_throw_exception('Failed to get current directory');

    print "# Syncing ", $self->maildir, " ...\n" if VERBOSITY;
    chdir $self->maildir or $self->_throw_exception('Maildir does not exist:', $self->maildir);

    mkdir 'cur' unless(-d 'cur');
    mkdir 'new' unless(-d 'new');
    mkdir 'tmp' unless(-d 'tmp');

    for my $box (@{ $self->mailboxes }) {
        print "# $box ...\n" if VERBOSITY;
        my $n_messages = $self->select($box) or $self->_throw_exception;

        for my $message_number (1..$n_messages) {
            $self->sync_message($message_number, $time);
        }

        $self->expunge_mailbox;
    }

    FILE:
    for my $basename ($self->tracked_emails) {
        if(my $file = $self->email_exists($basename)) {
            my $timestamp = ($file =~ /^(\d+)/)[0] or next FILE;
            if($timestamp < $time) {
                print "# deleted on server: $basename\n" if VERBOSITY;
                unlink $file;
                $self->untrack_mail($basename);
            }
        }
    }

    chdir $old_dir;
    return $self->write_mail_map;
}

=head2 sync_message

    $self->sync_message($message_number, $timestamp);

This method need to be called after called after C<chdir>ed to
the L</maildir>. It will do:

=over 4

=item *

Track and skip the file if it already exists on the filesystem

=item *

Delete the file from server if the file was previously tracked,
but no longer exists on the filesystem.

=item *

Download the file from server and store it on disk.

=back

=cut

sub sync_message {
    my($self, $message_number, $time) = @_;
    my($uid) = $self->uid($message_number);
    my $current_box = $self->current_box;

    if($self->email_exists($uid)) {
        print "# email exists $current_box/$uid\n" if VERBOSITY;
        $self->track_email($uid, $time);
        return '0e0';
    }
    elsif($self->email_is_tracked("$current_box/$uid")) {
        print "# will delete $current_box/$uid\n" if VERBOSITY;
        $self->remote_delete($message_number, $uid) if($self->can_delete);
        return -1;
    }
    else {
        my $basename = $self->track_email($uid, $time);
        print "# download $current_box/$uid => $basename\n" if VERBOSITY;
        my $IMAP_MAIL = $self->getfh($message_number) or $self->_throw_exception;
        open my $LOCAL_MAIL, '>', "tmp/$basename" or $self->_throw_exception("Write tmp/$basename: $!");
        print $LOCAL_MAIL $_ while(<$IMAP_MAIL>);
        close $LOCAL_MAIL or $self->_throw_exception("Close tmp/$basename: $!");
        link "tmp/$basename", "new/$basename" or $self->_throw_exception("link tmp/$basename => new/$basename: $!");
        unlink "tmp/$basename" or $self->_throw_exception("unlink tmp/$basename: $!");
        return 1;
    }
}

=head2 remote_delete

    $self->remote_delete($message_number, $uid);

Will delete an email on the server with the given C<$message_number> and
in the L<current mailbox|Net::IMAP::Simple/current_box>.

The email will be copied to trash first and the later expunge it if current
mailbox is l</trash_mailbox>.

=cut

sub remote_delete {
    my($self, $message_number, $uid) = @_;
    my $current_box = $self->current_box;
    my $trash_mailbox = $self->trash_mailbox;

    if($trash_mailbox eq $current_box) {
        printf "# expunge from %s: %s\n", $current_box, $uid if VERBOSITY;
    }
    else {
        printf "# move to %s: %s\n", $trash_mailbox, $uid if VERBOSITY;
        $self->copy($message_number, $trash_mailbox) or $self->_throw_exception;
    }

    $self->delete($message_number) or $self->_throw_exception;
    $self->untrack_mail(join '/', $current_box, $uid);

    return 1;
}

=head2 uid

Does the same as L<Net::IMAP::Simple/uid>, but will raise an exception
if no UID was returned.

=cut

sub uid {
    my $self = shift;
    my @uid = $self->_client->uid(@_);
    $self->_throw_exception unless(@uid);
    return @uid if(wantarray);
    return $uid[0];
}

=head2 write_mail_map

Will dump the tacked UID and file information to disk. This method
is the last thing L</sync> calls.

=cut

sub write_mail_map {
    my $self = shift;
    open my $MAP_FH, '>', $self->maildir ."/$MAIL_MAP";
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Purity = 1;
    print $MAP_FH Data::Dumper::Dumper($self->_mail_map);
    close $MAP_FH;
}

sub _throw_exception {
    my($self, @msg) = @_;
    @msg = ($self->errstr) unless(@msg);
    s/[\r\n]//g for(@msg);
    Carp::confess(join ' ', @msg);
}

=head2 new

    $self = $class->new(\%attr);

Object constructor. See L</ATTRIBUTES> for details on constructor arguments.

=cut

sub new {
    my $class = shift;
    my $args = ref $_[0] eq 'HASH' ? shift : {@_};
    my $self;

    if(my $mailboxes = $args->{'mailboxes'}) {
        $args->{'mailboxes'} = ref $mailboxes eq 'ARRAY' ? $mailboxes : [$mailboxes];
    }
    
    $self = $class->SUPER::new($args);
    $self->_build_username unless($self->username);
    $self->_build_password unless($self->password);
    
    return $self;
}

=head1 AUTOLOAD

Yes... I know C<AUTOLOAD> is evil. The rest of the methods available
on this object is proxied to L<Net::IMAP::Simple>.

=cut

sub AUTOLOAD {
    my $method = ($AUTOLOAD =~ /::(\w+)$/)[0];
    return if($method eq 'DESTROY');
    return shift->_client->$method(@_) if(Net::IMAP::Simple->can($method));
    Carp::confess("Cannot proxy method $method to Net::IMAP::Simple");
}

#=============================================================================

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen C<< jhthorsen at cpan.org >>

=cut

if($ENV{'TEST_SYNCIMAP'}) {
    __run_unittests();
}
elsif(!$ENV{'DO_NOT_RUN_SYNCIMAP'}) {
    exit App::SyncIMAP->new_with_options->run
}

sub __run_unittests {
    require File::Path;
    require Test::More;
    Test::More->import;
    mock_imap_simple();

    my(@ARGS, @UID, $UID, $client);
    my $CURRENT_BOX = 'INBOX';
    my $time = time;
    my %new = (
        username => 'john@foo.com',
        password => MIME::Base64::encode_base64('seCr3t'),
    );

    # constructor
    eval { App::SyncIMAP::Client->new };
    like($@, qr{username => }, 'client require username');
    eval { App::SyncIMAP::Client->new({ username => 'foo' }) };
    like($@, qr{password => }, 'client require password');

    # defaults
    $client = App::SyncIMAP::Client->new({ %new, port => 123 });
    is($client->ssl, 0, 'SSL is default off for port != 993');

    $client = App::SyncIMAP::Client->new(\%new);
    is($client->server, 'localhost', 'default server is localhost');
    is($client->port, 993, 'default port is 993');
    is($client->ssl, 1, 'SSL is default on for port 993');
    is($client->timeout, 10, 'default timeout is 10');
    is($client->maildir, 'Mail', 'default maildir is Mail');
    is($client->can_delete, 0, 'mail cannot be deleted by default');
    is($client->trash_mailbox, 'Trash', 'default trash_mailbox is Trash');
    is_deeply($client->_mail_map, {}, 'default _mail_map is an empty hash');

    # track_email and _mail_map
    $client->track_email(4, $time);
    is($client->_mail_map->{'remote_to_local'}{"INBOX/4"}, "$time-localhost-UID4", 'tracked file is stored internally');
    $client->track_email(5, $time);
    is_deeply([ $client->tracked_emails ], ["$time-localhost-UID4", "$time-localhost-UID5"], '4 and 5 is tracked');

    # untrack_mail
    $client->untrack_mail("$time-localhost-UID4");
    is($client->_mail_map->{'remote_to_local'}{'INBOX/4'}, undef, 'tracked file INBOX/4 got removed');

    # login
    isa_ok($client->_client, 'Net::IMAP::Simple');
    @ARGS = (); $client->login;
    is_deeply(\@ARGS, [qw/ login john@foo.com seCr3t /], 'Net::IMAP::Simple->login received username+password');

    # remote_delete
    $UID = 2;
    $client->track_email($UID, $time);
    is($client->_mail_map->{'remote_to_local'}{"INBOX/$UID"}, "$time-localhost-UID2", 'INBOX/2 is tracked...');
    @ARGS = (); $client->remote_delete(5, $UID);
    is_deeply(\@ARGS, ['copy', 5, 'Trash', 'delete', 5], 'remote_delete() issued move');
    is($client->_mail_map->{'remote_to_local'}{"INBOX/$UID"}, undef, '...INBOX/2 is not tracked');

    $CURRENT_BOX = 'Trash';
    $client->track_email($UID, $time);
    is($client->_mail_map->{'remote_to_local'}{"Trash/$UID"}, "$time-localhost-UID2", 'Trash/2 is tracked...');
    @ARGS = (); $client->remote_delete(5, 2);
    is_deeply(\@ARGS, ['delete', 5], 'remote_delete() issued delete (will be expunged)');
    is($client->_mail_map->{'remote_to_local'}{"Trash/$UID"}, undef, '...Trash/2 is not tracked');

    # sync_message
    local $! = 1;
    eval { $client->sync_message(5, $time) };
    like($@, qr{Operation not permitted}, 'sync_message() failed to get uid');

    @UID = ($UID=8);
    $CURRENT_BOX = 'INBOX';
    eval { $client->sync_message(5, $time) };
    like($@, qr{No such file or directory}, 'sync_message() failed to write to new/');
    #print Data::Dumper::Dumper($client->_mail_map);

    BAIL_OUT('Cannot run when new/ exists') if(-d 'new');
    BAIL_OUT('Cannot run when tmp/ exists') if(-d 'tmp');

    mkdir 'tmp';
    mkdir 'new';
    is($client->sync_message(5, $time), 1, 'sync_message == download');
    is(-s("new/$time-localhost-UID$UID"), 232, 'new/$time-localhost-UID8 has size');
    is($client->sync_message(5, $time), '0e0', 'sync_message == already synced');
    is($client->email_exists($UID, $time), "new/$time-localhost-UID$UID", 'email with UID 8 exists');

    rename "new/$time-localhost-UID$UID", "new/$time-localhost-UID$UID:2,TS" or die $!;
    is($client->email_exists($UID, $time), "new/$time-localhost-UID$UID", 'email with UID 8 was found, even after rename');

    unlink "new/$time-localhost-UID$UID:2,TS" or die $!;
    @ARGS = ();
    is($client->sync_message(5, $time), -1, 'sync_message == delete');
    is_deeply(\@ARGS, [], 'sync_message() skipped remote_delete()');
    $client->{'can_delete'} = 1;
    is($client->sync_message(5, $time), -1, 'sync_message == delete with can_delete=1');
    is_deeply(\@ARGS, ['copy', 5, 'Trash', 'delete', 5], 'sync_message() issued remote_delete()');

    File::Path::remove_tree('new');
    File::Path::remove_tree('tmp');

    # TODO: $client->sync;
    # TODO: $client->dump;
    done_testing();

    sub mock_imap_simple {
        my $data_pos = tell DATA;
        no warnings;
        *Net::IMAP::Simple::new = sub { bless {}, 'Net::IMAP::Simple' };
        *Net::IMAP::Simple::copy = sub { shift; push @ARGS, (copy => @_); };
        *Net::IMAP::Simple::current_box = sub { $CURRENT_BOX };
        *Net::IMAP::Simple::delete = sub { shift; push @ARGS, (delete => @_); };
        *Net::IMAP::Simple::errstr = sub { "$!" };
        *Net::IMAP::Simple::getfh = sub { seek DATA, $data_pos, 0; *DATA };
        *Net::IMAP::Simple::login = sub { shift; push @ARGS, (login => @_); };
        *Net::IMAP::Simple::uid = sub { @UID };
    }
}

__DATA__
MIME-Version: 1.0
Received: by 10.142.125.19 with HTTP; Sat, 12 Mar 2011 06:12:08 -0800 (PST)
Date: Sat, 12 Mar 2011 15:12:08 +0100
Delivered-To: john@foo.com
Subject: TEST
From: mr mutt <doe@foo.com>
To: john@foo.com

Some body...
