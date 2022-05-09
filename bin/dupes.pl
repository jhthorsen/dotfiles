#!/usr/bin/env perl
package File;
use Mojo::Base -base;
use Mojo::Util qw(sha1_sum);
use Number::Bytes::Human qw(format_bytes);
use overload
  '""'     => sub { shift->file->to_string },
  bool     => sub {1},
  fallback => 1;

$ENV{CHECKSUM_KB} //= 512;
$ENV{CHECKSUM_SALT} //= time;

has checksum => sub {
  my $self = shift;
  my $fh = $self->file->open;
  Carp::croak(qq{Can't read from file "$$self": $!})
    unless defined $fh->sysread(my $content, ($ENV{CHECKSUM_KB} * 1000), 0);
  return sha1_sum($content, $^T);
};

has file => undef;
has stat => sub { $_[0]->file->stat // die "stat $_[0]: $!" };

sub basename { shift->file->basename }
sub dirname { shift->file->dirname }
sub hsize    { format_bytes(shift->size) }
sub size     { shift->stat->size }

sub fix {
  my ($self, $other) = @_;
  my @other = @{$other->file};
  my $len   = @{$self->file};
  my @dir   = @{$self->dirname};
  my @to;

  while (1) {
    last if @to + @dir >= $len;
    unshift @to, pop @other;
  }

  return $self->new(dir => $self->dirname, file => $self->file->new(@dir, @to));
}

package main;
use Applify;
use Mojo::File;
use Mojo::IOLoop;
use Term::ANSIColor qw(colored);
use Time::Piece;

option str  => exec       => 'Ex: --exec rm --exec mv', [], n_of => '@';
option num  => concurrent => 'How many files to get checksum from at once', 5;
option flag => color      => 'Output with color';
option flag => dry_run    => 'Skip doing the operation';
option flag => rename     => 'Normalize basename - No dup checks';
option flag => progress   => 'Print progress';
option flag => verbose    => 'Print verbose output';

sub debug {
  my ($self, $key, $extra) = @_;
  my $t = time - $^T;
  warn "# [$key] t=$t $extra\n";
}

sub group_by_checksum {
  my ($self, $by_size) = @_;

  my ($n, $t, %by_checksum) = (0, time);
  Mojo::Promise->map({concurrency => $self->concurrent}, sub {
    my $by_size = shift;
    $n += @$by_size;

    if ($self->progress and time - 5 > $t) {
      $t = time;
      $self->debug(checksum => "n=$n k=@{[int keys %by_checksum]}") if $self->progress;
    }

    return Mojo::Promise->resolve if @$by_size <= 1;
    return Mojo::IOLoop->subprocess->run_p(sub { map { $_->checksum } @$by_size })->then(sub {
      for my $f (@$by_size) {
        $f->checksum(shift @_);
        my $key = join ':', $f->size, $f->checksum;
        push @{$by_checksum{$key}}, $f;
      }
    });
  }, values %$by_size)->wait;

  $self->debug(checksum => "n=$n k=@{[int keys %by_checksum]}") if $self->progress;
  return \%by_checksum;
}

sub group_by_size {
  my $self = shift;

  my ($n, %by_size) = (0);
  for my $dir (@_) {
    for my $file ($dir->list_tree->sort->each) {
      my $f = File->new(dir => $dir, file => $file);
      next unless -f $file and $file->stat->size;
      push @{$by_size{$f->size}}, $f;
      $n++;
    }
  }

  $self->debug(size => "n=$n k=@{[int keys %by_size]}") if $self->progress;

  return \%by_size;
}

sub exec_operations {
  my ($self, $by_checksum) = @_;
  my $exec_mv = $self->dry_run ? 0 : grep { $_ eq 'mv' } @{$self->exec};
  my $exec_rm = $self->dry_run ? 0 : grep { $_ eq 'rm' } @{$self->exec};

  my ($rename_if, $mv, $keep, $rm, @keep) = ('??', 0, 0, 0);
  for my $checksum (sort keys %$by_checksum) {
    my $dups = $by_checksum->{$checksum};
    @$dups = sort @$dups;
    my $first = shift @$dups;
    push @keep, $first;
    next unless @$dups;

    # See if we should rename a file
    my $rename;
    if ($first =~ m!\Q$rename_if\E!) {
      for my $other (@$dups) {
        next if $other->basename =~ m!\Q$rename_if\E!;
        $rename = $first->fix($other);
        last;
      }
    }

    # Print information about which file to keep and how many dups
    $self->info($first, '#' => qq("$first" (@{[int @$dups]})));

    # Rename after we have deleted duplicates
    for my $other (@$dups) {
      $self->info($other, rm => qq("$other"));
      $other->file->remove if $exec_rm;
      $rm++;
    }

    # Rename after we have deleted duplicates
    if ($rename and -e $rename) {
      $self->info($first, mv => join ' ', map {qq("$_")} $first, $rename) if $rename;
      $rename->file->dirname->make_path && $first->file->move_to($rename) if $rename and $exec_mv;
      $mv++;
    }
    else {
      $keep++;
    }
  }

  $self->debug(exec => "keep=$keep mv=$mv rm=$rm") if $self->progress;
  return 0;
}

sub exec_rename {
  my $self = shift;

  for my $dir (@_) {
    for my $f ($dir->list_tree->sort->each) {
      my $file = File->new(dir => $dir, file => $f);
      my $renamed = $file->basename;
      $renamed = sprintf '%s %s', localtime($file->stat->mtime)->ymd, $renamed =~ s!(\d\d\d\d)-?(\d\d)[ -]+!!r
        unless $renamed =~ s!^(\d\d\d\d)-?(\d\d)-?(\d\d)( -)?!$1-$2-$3!;
      next if $file->basename eq $renamed;
      $renamed = $file->file->sibling($renamed);
      next if -e $renamed;
      say qq(mv "$file" "$renamed");
      rename $file => $renamed unless $self->dry_run;
    }
  }

  return 0;
}

sub info {
  my ($self, $f, $action, $rest) = @_;
  my $str = $self->verbose
    ? sprintf "%6s %5s %-2s %s", substr($f->checksum, 0, 6), $f->hsize, $action, $rest
    : sprintf "%s %s", $action, $rest;

  state $color = {mv => 'yellow', rm => 'red'};
  printf "%s\n", $self->color ? colored($str, $color->{$action} || 'reset') : $str;
}

app {
  my $self = shift;
  return $self->_script->print_help, 0 unless @_;
  $self->debug(start => "p=@_") if $self->progress;
  return $self->exec_rename(map { Mojo::File->new($_)->to_abs } @_) if $self->rename;
  return $self->exec_operations($self->group_by_checksum($self->group_by_size(map { Mojo::File->new($_)->to_abs } @_)));
};
