#!/usr/bin/env perl

BEGIN {
    my @required = qw/ autodie Moose MooseX::Getopt Config::Tiny /;
    my @failed;

    for my $module (@required) {
        push @failed, $module unless(eval "use $module; 1");
    }

    if(@failed) {
        local $" = "\n    ";
        die <<"REQUIRED";
$0 requires:

    @failed

REQUIRED
    }
}

=head1 NAME

PurpleLogsToTpLogger - Can convert purple (pidgin) logs to tplogger (empathy)

=head1 SYNOPSIS

    purple-logs-to-tplogger.pl
    purple-logs-to-tplogger.pl \
        --purple-log-dir /path/to/input/logs \
        --tp-log-dir /path/to/output/logs

=cut

package PurpleLogsToTpLogger;

use Moose;
use Config::Tiny;
use autodie;

with 'MooseX::Getopt';

sub __read_dir { opendir my($DH), $_[0]; return grep { !/^\./ } readdir $DH }
sub __log { warn '[LOG] ', @_, "\n" }

=head1 ATTRIBUTES

=head2 purple_log_dir

=cut

has purple_log_dir => (
    is => 'ro',
    isa => 'Str',
    default => $ENV{'HOME'} .'/.purple/logs',
);

=head2 tp_log_dir

=cut

has tp_log_dir => (
    is => 'ro',
    isa => 'Str',
    default => $ENV{'HOME'} .'/.local/share/TpLogger/logs',
);

=head2 tp_accounts

=cut

has tp_accounts => (
    is => 'ro',
    isa => 'Config::Tiny',
    lazy_build => 1,
);

sub _build_tp_accounts {
    my $self = shift;
    my $file = $ENV{'HOME'} .'/.mission-control/accounts/accounts.cfg'; # need to coerce this

    return Config::Tiny->new->read($file);
}

=head1 METHODS

=head2 run

=cut

sub run {
    my $self = shift;
    my @types = @_;

    unless(@types) {
        @types = qw/ msn /;
    }

    TYPE:
    for my $type (@types) {
        my $method = "convert_$type";
        $self->$method;
    }

    return 0;
}

=head2 convert_msn

=cut

sub convert_msn {
    my $self = shift;
    my $source_dir = $self->purple_log_dir .'/msn';
    my $accounts = $self->tp_accounts;

    __log "Reading MSN logs from $source_dir...";

    SOURCE_ACCOUNT:
    for my $source_account (__read_dir($source_dir)) {
        my $target_account;

        TARGET_ACCOUNT:
        for(keys %$accounts) {
            if($accounts->{$_}{'param-account'} eq $source_account) {
                __log "Found MSN account $_ from telepathy config";
                $target_account = $_;
                $target_account =~ s,/,_,g;
                last TARGET_ACCOUNT;
            }
        }

        unless($target_account) {
            __log "Could not find MSN account $source_account in telepathy config";
            next SOURCE_ACCOUNT;
        }

        SOURCE_PARTNER:
        for my $source_partner (__read_dir("$source_dir/$source_account")) {
            $self->_convert_log_dir({
                source_dir => $source_dir,
                source_account => $source_account,
                source_partner => $source_partner,
                target_account => $target_account,
            });
        }
    }

    return 1;
}

sub _convert_log_dir {
    my($self, $args) = @_;
    my $log_dir = join '/', @$args{qw/ source_dir source_account source_partner /};
    my $parse_date = qr{^ (\d{4}) - (\d{2}) - (\d{2}) \. (\d{2})(\d{2})(\d{2}) \+ (\w+) }x;
    my $doc;

    LOG_FILE:
    for my $source_log (__read_dir($log_dir)) {
        my($messages, $source_date);

        if($source_log =~ $parse_date) {
            $source_date = { year => $1, month => $2, day => $3 };
        }
        else {
            __log "Failed to get date from ($source_log)";
            next LOG_FILE;
        }

        if($source_log =~ /\.html/) {
            $messages = $self->_parse_html(join '/', $log_dir, $source_log);
        }
        else {
            __log "Cannot convert $source_log";
            next LOG_FILE;
        }

        $self->_save_tp_log({
            target_account => $args->{'target_account'},
            partner => $args->{'source_partner'},
            me => $args->{'source_account'},
            source_date => $source_date,
            messages => $messages,
        });
    }

    return 1;
}

# this is probably the worst parser ever
# please convert to XML::LibXML or something else to make it saner...
# this is plain guesswork for now
sub _parse_html {
    my($self, $file) = @_;
    my @messages;
    my $re_line = qr{
        \( ([^\)]+) \) </font>\s*     # date
        <b> (.*?) :? </b> \s* </font> # partner
        (.*)                          # message
    }xi;

    open my $HTML, '<', $file;

    while(my $line = readline $HTML) {
        if($line =~ $re_line) {
            my($time, $name, $message) = ($1, $2, $3);

            # strip tags
            $message =~ s,</?\w+[^>]+>,,g; 
            $message =~ s/^\s+//;
            $message =~ s/\s+$//;

            if($time =~ / (\d+) : (\d+) : (\d+) \s+ (\w+) /x) {
                $time = { hour => $1, minute => $2, second => $3 };
                $time->{'hour'} += 12 if($4 =~ /PM/i);
            }

            push @messages, {
                time => $time,
                name => $name,
                message => $message,
                isuser => $line =~ /#16569E/i ? 1 : 0,
            };
        }
    }

    return \@messages;
}

# this is not good, but it's cheaper than loading a library to create
# the output logfile
sub _save_tp_log {
    my $self = shift;
    my $args = shift;
    my $target_log_dir = join '/', $self->tp_log_dir, @$args{qw/ target_account partner /};
    my $source_date = $args->{'source_date'};
    my $message_format = "<message time='%s' cm_id='%s' id='%s' name='%s' token='%s' isuser='%s' type='%s'>%s</log>";
    my($target_log_file, @stat, @log);

    if(!-d $target_log_dir) {
        __log "Creating target log directory: ($target_log_dir)...";
        mkdir $target_log_dir;
    }

    $target_log_file = join '/', $target_log_dir, join('', @$source_date{qw/ year month day /}, '.log');
    @stat = eval { stat $target_log_file };

    if(@stat and $stat[2] & 0700 == 0600) {
        __log "Logfile exists ($target_log_file)";
        return;
    }
    else {
        __log "Write logfile ($target_log_file)...";
    }

    push @log, (
        q(<?xml version='1.0' encoding='utf-8'?>),
        q(<?xml-stylesheet type="text/xsl" href="log-store-xml.xsl"?>),
        q(<log>),
    );

    for my $message (@{ $args->{'messages'} }) {
        my $message_time = $message->{'time'};

        push @log, sprintf($message_format,
            join('',
                @$source_date{qw/ year month day /},
                'T',
                join(':', @$message_time{qw/ hour minute second /}),
            ), # time
            '', # TODO cm_id
            $message->{'isuser'} ? $args->{'me'} : $args->{'partner'}, # id
            $message->{'name'}, # name
            '', # avatar token
            $message->{'isuser'} ? 'true' : 'false', # isuser
            'normal', # type
            $message->{'message'}, # message
        );
    }

    push @log, '</log>';

    open my $LOG, '>', $target_log_file;
    print $LOG map { "$_\n" } @log;

    return 1;
}

package main;
exit PurpleLogsToTpLogger->new->run;
