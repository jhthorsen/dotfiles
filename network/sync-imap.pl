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

=head1 NAME

App::SyncIMAP::Client

=head1 DESCRIPTION

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
use File::Path qw/ make_path /;
use Net::IMAP::Simple;
use MIME::Base64 ();
use constant VERBOSITY => defined $ENV{'VERBOSITY_SYNCIMAP'} ? $ENV{'VERBOSITY_SYNCIMAP'} : 1;
use base 'Class::Accessor::Fast::WithBuilder';

our $AUTOLOAD; # TODO: define fixed proxy methods instead
our $MAIL_MAP = '.mail_map';

=head1 ATTRIBUTES

=head2 maildir

Default "Maildir".

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
    _mail_map
));

sub _build_port { 993 }
sub _build_maildir { 'Maildir' }
sub _build_can_delete { 0 }
sub _build_trash_mailbox { 'Trash' }
sub _build_timeout { 10 }
sub _build_server { 'localhost' }
sub _build_ssl { shift->port eq '993' ? 1 : 0 }
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

=head2 track_file

    $self->track_file($file, $timestamp);

Will mark a file as tracked.

=head2 tracked_files

    @filenames = $self->tracked_files;

Returns a list of files relative to L</maildir>.

=head2 tracked_file_timestamp

    $int = $self->tracked_file_timestamp($file);

Will return an epoch time for the last time the file was tracked.
The timestamp is set inside L</sync>. Returns C<undef> if the file
is not tracked.

=cut

sub track_file { $_[0]->_mail_map->{'file_to_timestamp'}{$_[1]} = $_[2] }
sub tracked_files { keys %{ $_[0]->_mail_map->{'file_to_timestamp'} } }
sub tracked_file_timestamp { $_[0]->_mail_map->{'file_to_timestamp'}{$_[1]} || 0 }

=head2 untrack_file

    $self->untrack_file($file);

Will remove the tracking of the file in the internal storage.

=cut

sub untrack_file {
    my($self, $file) = @_;
    my $uid = delete $self->_mail_map->{'file_to_uid'}{$file};

    delete $self->_mail_map->{'file_to_timestamp'}{$file};
    delete $self->_mail_map->{'uid_to_file'}{$uid} if($uid);
}

=head2 uid_to_file

    $file = $self->uid_to_file($uid, $file);
    $file = $self->uid_to_file($uid);

The first will store the L<uid|Net::IMAP::Simple/uid> for a given file
and the second will simply return the uid if it exists. Returns
C<undef> if the uid is not mapped to a file.

=cut

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
    my $password = MIME::Base64::decodeselfe64($self->password);

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

    for my $box ($self->mailboxes) {
        push @{ $res{'mailboxes'} }, $box;
        printf "mailbox: /%s\n", $box if VERBOSITY;
    }
    #for my $box ($self->mailboxes_subscribed) {
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
L<files|/tracked_files> on disk which is not on the server.

=cut

sub sync {
    my $self = shift;
    my $time = time;
    my $old_dir = cwd or $self->_throw_exception('Failed to get current directory');

    print "Syncing ", $self->maildir, " ...\n" if VERBOSITY;
    chdir $self->maildir or $self->_throw_exception('Maildir does not exist:', $self->maildir);

    for my $box ($self->mailboxes) {
        my $n_messages = $self->select($box) or next;

        unless(-d $box) {
            print "> make_path '$box'\n" if VERBOSITY;
            make_path $box;
        }

        for my $message_number (1..$n_messages) {
            $self->sync_message($message_number, $time);
        }

        $self->expunge_mailbox;
    }

    FILE:
    for my $file ($self->tracked_files) {
        if($self->tracked_file_timestamp($file) < $time) {
            print "> deleted on server: $file\n" if VERBOSITY;
            unlink $file;
            $self->untrack_file($file);
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
    my($uid) = $self->uid($message_number) or $self->_throw_exception;
    my $current_box = $self->current_box;
    my $source = $self->uid_to_file($uid);
    my $file = "$current_box/$uid";

    if(-e $file) {
        $self->track_file($file, $time);
        $self->uid_to_file($uid, $file);
    }
    elsif($self->tracked_file_timestamp($file)) {
        $self->remote_delete($message_number, $file) if($self->can_delete);
    }
# TODO: How can this work? Looks like at least google mess up UID
# when making drafts...
#    elsif($source and -r $source) {
#        $source =~ s/^\.\.\///;
#        print "> link $source => $file\n" if VERBOSITY;
#        link $source => $file or $self->_throw_exception("link '$source' => '$file' failed: $!");
#    }
    else {
        print "> download $file\n" if VERBOSITY;
        my $IMAP_MAIL = $self->getfh($message_number) or $self->_throw_exception;
        open my $LOCAL_MAIL, '>', $file or $self->_throw_exception("Write $file: $!");
        print $LOCAL_MAIL $_ while(<$IMAP_MAIL>);
        $self->track_file($file, $time);
        $self->uid_to_file($uid, $file);
    }

    return 1;
}

=head2 remote_delete

    $self->remote_delete($message_number, $file);

Will delete an email on the server with the given C<$message_number> and
in the L<current mailbox|Net::IMAP::Simple/current_box>.

The email will be copied to trash first and the later expunge it if current
mailbox is l</trash_mailbox>.

=cut

sub remote_delete {
    my($self, $message_number, $file) = @_;
    my $current_box = $self->current_box;
    my $trash_mailbox = $self->trash_mailbox;

    if($trash_mailbox eq $current_box) {
        printf "> expunge from %s: %s\n", $current_box, $file if VERBOSITY;
    }
    else {
        printf "> move to %s: %s\n", $trash_mailbox, $file if VERBOSITY;
        $self->copy($message_number, $trash_mailbox) or $self->_throw_exception;
    }

    $self->delete($message_number) or $self->_throw_exception;
    $self->untrack_file($file);

    return 1;
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
    my $self = shift->SUPER::new(@_);

    # need to have a value
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
