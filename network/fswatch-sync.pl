#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::File 'path';
use Mojo::IOLoop::ReadWriteFork;

run(@ARGV);

sub run {
  my $app = bless {remote_host => shift, remote_path => shift, pwd => path->to_abs->to_string};
  die $app->usage unless $app->{remote_host} and $app->{remote_path};

  $app->{remote_path} =~ s!/+$!!;
  print "# Syncing $app->{pwd} => $app->{remote_host}:";
  die $app->usage unless 0 == system ssh => $app->{remote_host} => "ls -d $app->{remote_path}";

  my %files;
  $app->start_fswatch(\%files);
  $app->start_sftp;
  $app->watch_for_changes(\%files);
  Mojo::IOLoop->start;
}

sub start_fswatch {
  my ($app, $files) = @_;
  $app->{fswatch}->stop if $app->{fswatch};

  my @fswatch = ('fswatch', '-x', '--event-flag-separator=:', $app->{pwd});
  my $pid = open my $FSWATCH, '-|', @fswatch or die "> @fswatch: $!";
  my $fswatch = $app->{fswatch} = Mojo::IOLoop::Stream->new($FSWATCH)->timeout(0);
  $fswatch->on(close => sub { warn "CLOSE: $_[0]\n"; $app->start_fswatch($files) });
  $fswatch->on(error => sub { warn "ERR: $_[1]\n" });

  my $buf = '';
  my $n   = 0;
  $fswatch->on(read => sub {
    warn "[fswatch] >>> ($_[1])\n" if $ENV{DEBUG};
    $buf .= $_[1];
    $files->{$1} = [$n++, join ':', grep { $_ } $files->{$1}[1], $2] while $buf =~ s!(.+?)\s+(\S+)[\r\n]+!!;
  });

  warn "\$ @fswatch [$pid]\n";
  $fswatch->start;
}

sub start_sftp {
  my $app = shift;
  my $sftp = $app->{sftp} = Mojo::IOLoop::ReadWriteFork->new->conduit({type => 'pty'});
  $sftp->on(error => sub { warn "ERR: $_[1]\n" });
  $sftp->on(close => sub { warn "CLOSE: $_[0]\n"; $app->start_sftp });

  my $buf = '';
  $sftp->on(read  => sub {
    warn "[sftp] >>> ($_[1])\n" if $ENV{DEBUG};
    $buf .= $_[1];
    print "$1\n" while $buf =~ s!(.*?)[\r\n]+!!;
  });

  $sftp->run(sftp => $app->{remote_host});
}

sub usage {
  "Usage: $0 ssh.example.com /sync/to/directory\n";
}

sub watch_for_changes {
  my ($app, $files) = @_;
  my $pwd_re = quotemeta $app->{pwd};

  Mojo::IOLoop->recurring(1 => sub {
    my %todo;
    for my $file (sort { $files->{$a}[0] <=> $files->{$b}[0] } keys %$files) {
      my $op  = $files->{$file}[1];
      my $rel = $file;
      print "# $op $file\n";
      next unless $rel =~ s!^$pwd_re!!;
      next if $op !~ /IsFile/;
      next if $op =~ /Created.*Removed/ or $op =~ /Removed.*Renamed/;

      if ($op =~ /Removed/) {
        $app->{sftp}->write("rm $app->{remote_path}$rel\n");
      }
      else {
        $app->{sftp}->write("put $file $app->{remote_path}$rel\n");
      }
    }

    %$files = ();
  });
}
