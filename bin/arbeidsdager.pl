#!/usr/bin/env perl
use Mojolicious::Lite;
use List::Util 'reduce';
use Time::Piece;
use Time::Seconds;

sub off {
  return (
    '01-01' => 'Nyttårsdag',
    '04-02' => 'Skjærtorsdag',
    '04-03' => 'Langfredag',
    '04-05' => '1. påskedag',
    '04-06' => '2. påskedag',
    '05-01' => 'Arbeidernes dag',
    '05-14' => 'Kristi Himmelfartsdag',
    '05-17' => 'Grunnlovsdag',
    '05-24' => '1. pinsedag',
    '05-25' => '2. pinsedag',
    '12-25' => '1. juledag',
    '12-26' => '2. juledag',
  );
}

sub christmas {
  my ($t, $off) = @_;
  my $ft = $off->{_christmas_ft} ||= do {
    my ($start) = grep { $off->{$_} and $off->{$_} eq '1. juledag' } keys %$off;
    $start = Time::Piece->strptime("$off->{year}-$start", '%Y-%m-%d') - ONE_DAY;
    [$start->epoch, ($start + 7 * ONE_DAY)->epoch];
  };

  return $t->epoch >= $ft->[0] && $t->epoch <= $ft->[1];
}

sub easter {
  my ($t, $off) = @_;
  my $ft = $off->{_easter_ft} ||= do {
    my ($end) = grep { $off->{$_} and $off->{$_} eq '2. påskedag' } keys %$off;
    $end = Time::Piece->strptime("$off->{year}-$end", '%Y-%m-%d');
    [($end - 7 * ONE_DAY)->epoch, $end->epoch];
  };

  return $t->epoch >= $ft->[0] && $t->epoch <= $ft->[1];
}

get '/' => sub {
  my $c    = shift;
  my $end  = $c->param('until') || 'today';
  my $year = $end =~ /(\d\d\d\d)/ ? $1 : localtime->year;
  my $t    = Time::Piece->strptime("${year}-01-01T00:00:00", '%Y-%m-%dT%H:%M:%S');
  my %off  = off();
  my $days = 0;

  map { $c->param($_ => 1) } qw( christmas easter weekends ) unless defined $c->param('vacation_days');
  $end = $end =~ /\d/ ? Time::Piece->strptime("${end}T23:59:59", '%Y-%m-%dT%H:%M:%S') : Time::Piece->new;

  $off{holiday}   = 0;
  $off{year}      = $year;
  $off{vacation_days} = $c->param('vacation_days');
  $off{christmas} = $c->param('christmas') ? 0 : undef;
  $off{easter}    = $c->param('easter') ? 0 : undef;
  $off{weekends}  = $c->param('weekends') ? 0 : undef;

  while (1) {
    last if $t >= $end;

    if ($off{$t->strftime('%m-%d')}) {
      $off{holiday}++;
    }
    elsif (defined $off{weekends} and $t->day =~ /^(?:Sat|Sun)/) {
      $off{weekends}++;
    }
    elsif (defined $off{easter} and easter($t, \%off)) {
      $off{easter}++;
    }
    elsif (defined $off{christmas} and christmas($t, \%off)) {
      $off{christmas}++;
    }
  }
  continue {
    $days++;
    $t += ONE_DAY;
  }

  $off{total} = reduce { $a + $b } map { $off{$_} || 0 } qw( weekends easter christmas holiday vacation_days );
  $c->render(end => $end, days => $days, off => \%off, year => $year);
}, 'index';

app->start;

__DATA__
@@ index.html.ep
<html>
  <head>
    <title>Arbeidsdager <%= $year%></title>
    %= stylesheet begin
    body, input { margin: 0; padding: 0; font-size: 13px font-family: sans-serif; }
    th { text-align: left; border-bottom: 1px solid #888; }
    table { border-collapse: collapse; }
    table td { padding: 1px; }
    tfoot td { border-bottom: 4px double #888; border-top: 1px solid #888; }
    .container { max-width: 24em; margin: 1em auto; }
    % end
  </head>
  <body>
    <div class="container">
      <h2>Arbeidsdager i <%= $year %></h2>
      %= form_for 'index', begin
        <table>
          <thead>
            <tr>
              <th>&nbsp;</th>
              <th>Beskrivelse</th>
              <th>Dager</th>
              <th>&nbsp;</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>&#160;</td>
              <td><%= $year %>-01-01 til <%= text_field until => 'i dag', placeholder => '2015-12-31', style => 'width:6em;border:0;outline:1px dotted #777' %></td>
              <td><%= $days %></td>
              <td>&#160;</td>
            </tr>
            <tr>
              <td>-</td>
              <td>Lør- og søndag</td>
              <td><%= $off->{weekends} || 0 %></td>
              <td><%= check_box weekends => 1, defined $off->{weekends} ? (checked => 'checked') : () %></td>
            </tr>
            <tr>
              <td>-</td>
              <td>Feriedager</td>
              <td><%= text_field vacation_days => 0, size => 2 %></td>
              <td>&#160;</td>
            </tr>
            <tr>
              <td>-</td>
              <td>Hellig- og høytidsdager</td>
              <td><%= $off->{holiday} || 0 %></td>
              <td>&#160;</td>
            </tr>
            <tr>
              <td>-</td>
              <td>Påske</td>
              <td><%= $off->{easter} || 0 %></td>
              <td><%= check_box easter => 1, defined $off->{easter} ? (checked => 'checked') : () %></td>
            </tr>
            <tr>
              <td>-</td>
              <td>Jul</td>
              <td><%= $off->{christmas} || 0 %></td>
              <td><%= check_box christmas => 1, defined $off->{christmas} ? (checked => 'checked') : () %></td>
            </tr>
          </tbody>
          <tfoot>
            <tr style="border-top:1px solid #000;">
              <td>=</td>
              <td>Arbeidsdager</td>
              <td title="<%= 7.5 * ($days - $off->{total}) %> timer"><%= $days - $off->{total} %></td>
              <td><%= submit_button 'Oppdater' %></td>
            </tr>
          </tfoot>
        </table>
      % end
    </div>
  </body>
</html>
