#!/usr/bin/perl

use strict;
use warnings;
use File::Find::Rule;

die "require ./lib directory" unless(-d './lib');
die "require ./t directory" unless(-d './t');

my @modules;
my $n = 0;
my $rule = File::Find::Rule
            ->file
            ->name('*.pm')
            ->start('lib');

while(my $file = $rule->match) {
    my $module = $file;
    $module =~ s,.pm$,,;
    $module =~ s,lib/?,,;
    $module =~ s,/,::,g;
    push @modules, $module;
    $n++;
}

open my $USE_OK, '>', 't/00-load.t' or die $!;
#open my $USE_OK, '>&', \*STDOUT;

print $USE_OK <<"HEAD";
#!/usr/bin/perl
use lib q(lib);
use Test::More tests => $n;
HEAD

for my $module (sort { length $a <=> length $b } @modules) {
    printf "use %s\n", $module;
    printf $USE_OK "use_ok('%s');\n", $module;
}

close $USE_OK;
exit;
