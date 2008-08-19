#!/usr/bin/perl

use strict;
use warnings;
use YAML;

my $meta = load_yaml() or die "No config";

open(my $mkfile, ">", "Makefile.PL") or die $!;
print $mkfile "$_;\n" for(
    qq(use inc::Module::Install),
    qq(name '$meta->{name}'),
    qq(abstract '$meta->{abstract}'),
    qq(author '$meta->{author}'),
    qq(all_from '$meta->{version_from}'),
    requires(),
    recommends(),
    test_requires(),
    qq(WriteAll),
);
close $mkfile;

sub recommends {
}

sub requires {
    map {
        qq(requires '$_' => $meta->{requires}{$_})
    } keys %{ $meta->{requires} };
}

sub test_requires {
    map {
        qq(test_requires '$_' => $meta->{build_requires}{$_})
    } keys %{ $meta->{build_requires} };
}

sub load_yaml {
	my $file = "META.yml";
	my $yaml = q();

    open(my $fh, "<", $file) or die "Could not read YAML: $!";

    LINE:
    while(my $line = readline $fh) {
        next LINE if($line =~ /^\s*\-{3}/);
        next LINE if($line =~ /^\s*#/);
        next LINE if($line =~ /^\s*$/);
        $yaml .= $line;
    }

    close $fh;
    return Load($yaml);
}

