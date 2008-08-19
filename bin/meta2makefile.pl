#!/usr/bin/perl

use strict;
use warnings;
use YAML;

our $VERSION = 0.1;
my $META;

chdir $ARGV[0] if($ARGV[0]);
load_yaml();
write_makefile();
exit 0;

=head1 NAME

meta2makefile.pl - a META.yml to Makefile.PL generator

=head1 VERSION

0.1

=head1 DESCRIPTION

Change directory to the first argument, or looks for META.yml in the current
directory.
Takes the information from META.yml and creates Makefile.PL.
Will overwrite existing Makefile.PL without asking!

=head1 USAGE

 $ meta2makefile.pl /path/to/my/module/

=head1 FUNCTIONS

=head2 write_makefile()

Takes information from <$META> and writes Makefile.PL to the current
directory.

=cut

sub write_makefile {
    my $get = sub {
        my($make_sub, $yaml_key) = @_;
        return unless(ref $META->{$yaml_key} eq 'HASH');
        return map {
                   qq($make_sub '$_' => $META->{$yaml_key}{$_})
               } keys %{ $META->{$yaml_key} };
    };

    open(my $mkfile, ">", "Makefile.PL")
        or die "Could not write Makefile.PL: $!";

    for(map { "$_;\n" }
        qq(use inc::Module::Install),
        qq(name '$META->{name}'),
        qq(abstract '$META->{abstract}'),
        qq(author '$META->{author}'),
        qq(all_from '$META->{version_from}'),
        $get->(requires => 'requires'),
        $get->(test_requires => 'build_requires'),
        qq(WriteAll),
    ) {
        print $mkfile $_;
        print;
    }

    close $mkfile;
}

=head2 load_yml()

Loads META.yml from the current directory and stores the datastructure in
C<$META>.

=cut

sub load_yaml {
	my $yaml = q();

    open(my $fh, "<", "META.yml") or die "Could not read META.yml: $!";

    LINE:
    while(my $line = readline $fh) {
        next LINE if($line =~ /^\s*\-{3}/);
        next LINE if($line =~ /^\s*#/);
        next LINE if($line =~ /^\s*$/);
        $yaml .= $line;
    }

    $META = Load($yaml) or die "No meta-data!";
}

