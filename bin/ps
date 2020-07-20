#!/usr/bin/env perl
package App::ps;
use strict;
use warnings;

# This application will reformat the output from "ps" if the "f"
# option is supplied. "f" on Linux will draw the output as a tree,
# but this is not supported on Mac OSX.
#
# This program can/will also add color to the "f" output.
#
# All other "ps" options should work as expected.
#
# Example usage:
# ps f
# ps -af
# ps f --color -o pid,command | less
# ps f --no-color -o command

# black, blue, cyan, green, magenta, red, yellow, white
$ENV{PS_COLOR_CMD}    ||= 'green';
$ENV{PS_COLOR_INDENT} ||= 'yellow';
$ENV{PS_COLOR_EVEN}   ||= 'bold';
$ENV{PS_COLOR_ODD}    ||= 'none';
$ENV{PS_COLOR_PRE}    ||= 'none';

$ENV{PS_DEBUG} ||= 0;           # Extra debug output
$ENV{COLUMNS}  ||= 0;           # Default to COLUMNS from the active terminal
$ENV{PS_BIN}   ||= '/bin/ps';   # Location of the "real" ps command

# accessors
sub argv            { @{$_[0]->{argv}} }
sub normalized_argv { @{$_[0]->{normalized_argv} || $_[0]->{argv}} }
sub system_ps       { $^O ne 'darwin' ? 1 : !$_[0]->{has_f} }

# methods
sub color {
  my ($self, $color) = @_;
  return $self->{color} && $color ne 'none' ? Term::ANSIColor::color($color) : '';
}

sub normalize_argv {
  my $self = shift;
  my @argv = $self->argv;

  @$self{qw(color has_f has_o has_w)} = (-t STDOUT, 0, -1, 0);

  # Check if we have "f", "-f" or something in the command
  no warnings 'qw';
  for (@argv) {
    $self->{has_f} = 1 if s!(-*\w*)f(.*)!$1$2!g;
    $self->{has_top} = 1 if m!--top!;
  }

  if ($self->{has_top}) {
    push @argv, '-e' if @argv == 1;
    $self->{argv} = [map { /^--top/ ? qw(-ww -o uid,%cpu,%mem,pid,command) : $_} @argv];
  }

  return $self unless $self->{has_f};

  # Check if we have "o", "-o" or something in the command
  for my $i (0 .. (@argv - 1)) {
    $self->{color} = $1 ? 0 : 1 if $argv[$i] =~ s!^--(no-)?color!!;
    $self->{has_o} = $i if $argv[$i]            =~ m!^-?o!;
    $self->{has_o} = -2 if $i == 0 && $argv[$i] =~ s!^([^o]*)o(\w*)$!$1$2!;
    $self->{has_w} += length $2 if $argv[$i] =~ s!(-*[^w]*)(w+)(.*)!$1$3!g;
  }

  # Add default format or prepend -o with "ppid"
  if ($self->{has_o} == -1) {
    push @argv, qw(-o pid,ppid,pid,tty,stat,time,command);
  }
  elsif ($self->{has_o} == -2) {
    splice @argv, 1, 0, qw(-o pid,ppid -o);
  }
  else {
    splice @argv, $self->{has_o}, 0, qw(-o pid,ppid);
  }

  @argv = grep length, @argv;
  warn "[App::ps] argv = @argv\n" if $ENV{PS_DEBUG};
  $self->{normalized_argv} = [@argv];

  return $self;
}

sub run {
  my $self = shift;

  # Check for --color support
  $self->{color} = eval 'require Term::ANSIColor;1' if $self->{color};

  require Term::ReadKey;
  $ENV{COLUMNS} ||= (Term::ReadKey::GetTerminalSize())[0];
  $ENV{ROWS}    ||= (Term::ReadKey::GetTerminalSize())[1];

  # Run unit tests
  return $self->test if grep /^--test/, $self->argv;

  # top alternative
  return $self->top_command if $self->{has_top};

  # Execute native ps
  exec $ENV{PS_BIN}, $self->argv if $self->system_ps;

  # Print tree (-f)
  $self->tree_make->tree_print;

  # Exit
  return $? || $! || 0;
}

sub shorten_cmd {
  my ($self, $indent, $out) = @_;
  return $out->[1] if $self->{has_w} >= 2;

  my $pre_len = length join '', $out->[0], $indent;
  return substr $out->[1], 0, 132 - $pre_len if $self->{has_w};
  return substr $out->[1], 0, $ENV{COLUMNS} - $pre_len;
}

sub test {
  no warnings 'qw';

  # (@argv, [$has_f, $has_o, @ps_argv], 'description')
  test_ok([],                    [qw(0 -1)],                       'ps');
  test_ok(['ax'],                [qw(0 -1 ax)],                    'ps ax');
  test_ok(['-xfa', '-o', 'cpu'], [qw(1 1 -xa -o pid,ppid -o cpu)], 'ps -xfa -o cpu');
  test_ok(['fao', 'cpu'],        [qw(1 -2 a -o pid,ppid -o cpu)],  'ps fao cpu');
  test_ok(['fo', 'ppid'],        [qw(1 -2 -o pid,ppid -o ppid)],   'ps fo ppid');
  test_ok(['axf'],               [qw(1 -1 ax -o pid,ppid,pid,tty,stat,time,command)], 'ps axf');

  Test::More::done_testing();
  return 0;
}

sub test_ok {
  require Test::More;
  my $argv = shift;
  my $app  = App::ps->new(@$argv)->normalize_argv;
  Test::More::is_deeply([$app->{has_f}, $app->{has_o}, $app->argv], @_)
    or Test::More::diag(join ' ', $app->argv);
}

sub top_command {
  my $self = shift;

  my $clear_screen = "\033[2J";
  my $top_left     = "\033[0;0H";
  $ENV{TOP_INTERVAL} ||= 3;

  print $clear_screen;
  while (1) {
    print $top_left;
    $self->top_make;
    $self->top_print($ENV{ROWS} - 6);
    printf "%s\n", ('-' x $ENV{COLUMNS});
    $self->uptime_print;
    sleep $ENV{TOP_INTERVAL};
  }
}

sub top_make {
  my $self = shift;
  @$self{qw(heading top)} = ('', {});

  require File::Basename;
  require List::Util;
  open my $PS, '-|', $ENV{PS_BIN}, $self->normalized_argv or die "[App:ps] Could not run $ENV{PS_BIN}: $!";
  while (<$PS>) {
    chomp;
    warn "[App::ps] out = $_\n" if $ENV{PS_DEBUG};
    $_ =~ s!^\s+!!;
    my ($uid, $cpu, $mem, $pid, $command) = split /\s+/, $_, 5;
    next unless $cpu =~ m!^\d+!;

    my ($comm) = split /\s/, $command, 2;
    my $item = $self->{top}{"$uid:$comm"} ||= [[], [], $pid, File::Basename::basename($comm)];
    push @{$item->[0]}, $cpu;
    push @{$item->[1]}, $mem;
  }

  $self->{top} = [
    sort {
      $b->[0] <=> $a->[0];
    } map {
      $_->[0] = List::Util::sum(@{$_->[0]}) / @{$_->[0]};
      $_->[1] = List::Util::sum(@{$_->[1]}) / @{$_->[1]};
      $_;
    } values %{$self->{top}}
  ];

  return $self;
}

sub top_print {
  my ($self, $max_rows) = @_;
  my $nodes = $self->{top} || [];

  printf "%-7s  %6s  %6s   %s\n", 'PID', 'CPU', 'MEM', 'COMMAND';
  printf "%s\n", ('-' x $ENV{COLUMNS});

  my $r = 0;
  my $w = $ENV{COLUMNS} - 27;
  for my $node (@$nodes) {
    next unless $node->[0] + $node->[1] > 0.1;
    my $comm = sprintf "%-${w}s", substr $node->[3], 0, $w;
    printf "%-7s  %6.1f  %6.1f   %s\n", $node->[2], $node->[0], $node->[1], $comm;
    last if ++$r > $max_rows;
  }

  print ' ' x ($ENV{COLUMNS}), "\n" for $r..$max_rows;
  return $self;
}

sub tree_make {
  my $self = shift;
  @$self{qw(heading root tree)} = ('', undef, {});

  open my $PS, '-|', $ENV{PS_BIN}, $self->normalized_argv or die "[App:ps] Could not run $ENV{PS_BIN}: $!";
  while (<$PS>) {
    chomp;
    warn "[App::ps] invalid = $_\n" and next unless s!^\s*(\w+)\s+(\w+)!!;    # pid,ppid,...
    warn "[App::ps] out = $_\n" if $ENV{PS_DEBUG};
    my ($pid, $ppid, $out) = ($1, $2, $_);

    # Parse heading PID, PPID, ...
    unless ($pid =~ /^\d+$/) {
      $self->{heading} = $out;
      my @chunks = $out =~ m!(\s*\w+\s+)!g;
      my $len = 0;
      $len += length $chunks[$_] for 0 .. (@chunks - 1);
      $self->{re} = qr/^(.{$len})(.*)/;
      next;
    }

    # Create process tree
    $self->{tree}{$pid}{out} = [$out =~ $self->{re}];
    $self->{tree}{$pid}{pid} = $pid;
    push @{$self->{tree}{$ppid}{kids}}, $self->{tree}{$pid};
    $self->{root} ||= $self->{tree}{$ppid};
  }

  return $self;
}

sub tree_print {
  my $self  = shift;
  my $nodes = shift || $self->{root}{kids} || [];
  my $depth = shift || 0;

  printf "%s\n", $self->{heading} if !$depth and length $self->{heading};

  for my $node (@$nodes) {
    my @out = @{$node->{out} || []};
    unshift @out, '' if @out == 1;
    $out[1] //= '';

    my $indent = $depth ? ' ' x ($depth * 4 - 2) : '';
    $indent .= '\_ ' if $depth;

    print $self->color($depth % 2 ? $ENV{PS_COLOR_ODD} : $ENV{PS_COLOR_EVEN});
    print join '',
      $self->color($ENV{PS_COLOR_PRE}),
      $out[0],
      $self->color($ENV{PS_COLOR_INDENT}),
      $indent,
      $self->color($ENV{PS_COLOR_CMD}),
      $self->shorten_cmd($indent, \@out),
      $self->color('reset'),
      "\n";

    $self->tree_print($node->{kids}, $depth + 1) if $node->{kids};
  }
}

sub uptime_print {
  my $self = shift;
  my $cols = $ENV{COLUMNS} - 1;
  my $uptime = qx{uptime};
  $uptime =~ s!^\s+!!;
  chomp $uptime;
  local $| = 1;
  printf "%-${cols}s", $uptime;
  return $self;
}

# constructor
sub new {
  my ($class, @argv) = @_;
  return bless {argv => [@argv]}, $class;
}

exit App::ps->new(@ARGV)->normalize_argv->run;
