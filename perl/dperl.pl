#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use File::Basename;
use File::Find;
use YAML::Tiny;

if(@ARGV == 0) {
    help();
    exit 1;
}
elsif(@ARGV ~~ /dperl.yml/) {
    dperl_yml();
    exit 0;
}
elsif(@ARGV ~~ /man/) {
    system perldoc => $0;
    exit $?;
}

our $CONFIG = YAML::Tiny->read('dperl.yml');
our $NAME = $CONFIG->[0]{'name'} || basename getcwd;
our $TOP_MODULE;
our $VERSION;

my $version_re = qr/\d+ \. \w+/x;

name_to_module();

if(@ARGV ~~ /update/) {
    clean();
    print "* Create/update t/00-load.t and t/99-pod*t\n";
    t_compile();
    t_pod();
    changes();
    print "* Create/update README\n";
    readme();
    print "* Repository got updated\n";
}
elsif(@ARGV ~~ /build/) {
    clean();
    print "* Create/update t/00-load.t and t/99-pod*t\n";
    t_compile();
    t_pod();
    print "* Update Changes\n";
    changes('update');
    print "* Create/update README\n";
    readme();
    print "* Build $NAME\n";
    makefile();
    manifest();
    meta_yml();
    dist();
    print "* $NAME got built\n";
}
elsif(@ARGV ~~ /release/) {
    release();
}
elsif(@ARGV ~~ /share/) {
    changes();
    share();
    print "* $NAME got shared\n";
}
elsif(@ARGV ~~ /test/) {
    clean();
    t_compile();
    t_pod();
    makefile();
    test();
}
elsif(@ARGV ~~ /clean/) {
    clean();
    print "$NAME got cleaned\n";
}
else {
    help();
    exit 1;
}

exit 0;

#=============================================================================
sub vsystem {
    print "> @_\n";
    system @_;
}

sub dperl_yml {
    print <<"DPERL";
# Example dperl.yml:
---
requires:
  namespace::autoclean: 0.02
  Catalyst: 5.8
test_requires:
  Test::More: 0.9
resources:
  bugtracker: http://rt.cpan.org/NoAuth/Bugs.html?Dist=Foo-Bar
  homepage: foo.com
  repository: http://github.com/wall-e/foo-bar

DPERL
}

sub help {
    my $do_print;

    open my $MAN, '<', $0 or die "Read '$0': $!";

    while(<$MAN>) {
        if($do_print and /^=/) {
            last;
        }
        elsif($do_print) {
            print;
        }
        elsif(/^=head1 SYNOPSIS/) {
            $do_print = 1;
        }
    }
}

sub name_to_module {
    my @path = split /-/, $NAME;
    my $path = 'lib';
    my $file;

    $path[-1] .= ".pm";

    for my $p (@path) {
        opendir my $DH, $path or die "Cannot find top module from project name '$NAME': $!\n";
        for my $f (readdir $DH) {
            if(lc $f eq lc $p) {
                $path = "$path/$f";
                last;
            }
        }
    }
    
    unless(-f $path) {
        die "Cannot find top module from project name '$NAME': $path is not a plain file\n";
    }

    $NAME = $path;
    $NAME =~ s,lib/,,;
    $NAME =~ s,\.pm,,;
    $NAME =~ s,/,-,g;
    $TOP_MODULE = $path;
}

sub release {
    my $commit_msg;

    open my $CHANGES, '<', 'Changes' or die "Read 'Changes': $!\n";

    while(<$CHANGES>) {
        if($commit_msg) {
            if(/^$/) {
                last;
            }
            else {
                $commit_msg .= $_;
            }
        }
        elsif(/^($version_re)\s+\w+.*$/) {
            $VERSION = $1;
            $commit_msg = $_;
        }
    }

    unless($VERSION) {
        die "Could not find \$VERSION from Changes\n";
    }
    unless(-e "$NAME-$VERSION.tar.gz") {
        die "Need to run with -build first\n";
    }

    vsystem git => commit => -a => -m => $commit_msg;
    vsystem git => tag => $VERSION;
}

sub share {
    eval "use CPAN::Uploader; 1" or die "This feature requires 'CPAN::Uploader' to be installed";

    my $file = "$NAME-$VERSION.tar.gz";
    my $pause = get_pause_info();
    my $branch = qx/git branch|grep "^*"|cut -d' ' -f2/;

    chomp $branch;

    unless(-e $file) {
        die "Need to run with -build first\n";
    }

    vsystem git => push => origin => $branch;
    vsystem git => push => '--tags' => 'origin';
    return;

    # might die...
    CPAN::Uploader->new($file, {
        user => $pause->{'user'},
        password => $pause->{'password'},
    });
}

sub get_pause_info {
    my $info;

    open my $PAUSE, '<', $ENV{'HOME'} .'/.pause' or die "Read ~/.pause: $!\n";

    while(<$PAUSE>) {
        my($k, $v) = split /\s+/, $_, 2;
        chomp $v;
        $info->{$k} = $v;
    }

    die "'user <name>' is not set in ~/.pause\n" unless $info->{'user'};
    die "'password <mysecret>' is not set in ~/.pause\n" unless $info->{'password'};

    return $info;
}

sub changes {
    my $date = qx/date/;
    my($changes, $pm);

    chomp $date;

    open my $CHANGES, '+<', 'Changes' or die "Read/write 'Changes': $!\n";
    { local $/; $changes = <$CHANGES> };

    if($_[0] and $changes =~ s/\n($version_re)\s*$/{ sprintf "\n%-7s  %s", $1, $date }/em) {
        $VERSION = $1;
    }
    elsif($changes =~ /\n($version_re)\s+/) {
        $VERSION = $1;
    }
    else {
        die "Could not find \$VERSION from Changes\n";
    }

    seek $CHANGES, 0, 0;
    print $CHANGES $changes;

    open my $PM, '+<', $TOP_MODULE or die "Read/write '$TOP_MODULE': $!\n";
    { local $/; $pm = <$PM> };
    $pm =~ s/=head1 VERSION.*?\n=/=head1 VERSION\n\n$VERSION\n\n=/s;
    $pm =~ s/\$VERSION\s*=.*$/\$VERSION = '$VERSION';/m;

    seek $PM, 0, 0;
    print $PM $pm;
}

sub readme {
    vsystem "perldoc -tT $TOP_MODULE > README";
}

sub clean {
    vsystem "make clean 2>/dev/null";
    vsystem "rm -r $NAME* META.yml MANIFEST* Makefile* blib/ inc/ 2>/dev/null";
}

sub test {
    vsystem make => 'test';
}

sub makefile {
    open my $MAKEFILE, '>', 'Makefile.PL' or die "Write 'Makefile.PL': $!\n";
    printf $MAKEFILE "use inc::Module::Install;\n";
    printf $MAKEFILE "name q(%s);\n", $NAME;
    printf $MAKEFILE "all_from q(%s);\n", $TOP_MODULE;

    if(my $req = $CONFIG->[0]{'requires'}) {
        for my $name (sort keys %$req) {
            printf $MAKEFILE "requires q(%s) => %s;\n", $name, $req->{$name} || 0;
        }
    }

    if(my $req = $CONFIG->[0]{'test_requires'}) {
        for my $name (sort keys %$req) {
            printf $MAKEFILE "test_requires q(%s) => %s;\n", $name, $req->{$name} || 0;
        }
    }

    print $MAKEFILE "auto_install;\n";
    print $MAKEFILE "WriteAll;\n";

    vsystem "perl Makefile.PL";
}

sub manifest {
    open my $SKIP, '>', 'MANIFEST.SKIP' or die "Write 'MANIFEST.SKIP': $!\n";
    print $SKIP "$_\n" for qw(
                           ^dperl.yml
                           .git
                           \.old
                           \.swp
                           ~$
                           ^blib/
                           ^Makefile$
                           ^MANIFEST.*
                       ), $NAME;

    vsystem "make manifest" and die "Execute 'make manifest': $!\n";
}

sub dist {
    vsystem "rm $NAME* 2>/dev/null";
    vsystem "make dist" and die "Execute 'make dist': $!";
}

sub meta_yml {
    my $meta = YAML::Tiny->read('META.yml');

    if(my $r = $CONFIG->[0]{'resources'}) {
        for my $k (keys %$r) {
            $meta->[0]{'resources'}{$k} = $r->{$k};
        }
    }

    $meta->write('META.yml');
}

sub t_header {
    return <<'HEADER';
#!/usr/bin/perl
use lib qw(lib);
use Test::More;
HEADER
}

sub t_pod {
    open my $POD_COVERAGE, '>', 't/99-pod-coverage.t' or die "Write 't/99-pod-coverage.t': $!\n";
    print $POD_COVERAGE t_header();
    print $POD_COVERAGE <<'TEST';
eval 'use Test::Pod::Coverage; 1' or plan skip_all => 'Test::Pod::Coverage required';
all_pod_coverage_ok();
TEST

    open my $POD, '>', 't/99-pod.t' or die "Write 't/99-pod.t': $!\n";
    print $POD t_header();
    print $POD <<'TEST';
eval 'use Test::Pod; 1' or plan skip_all => 'Test::Pod required';
all_pod_files_ok();
TEST
}

sub t_compile {
    my @modules;

    finddepth(sub {
        return unless($File::Find::name =~ /\.pm$/);
        $File::Find::name =~ s,.pm$,,;
        $File::Find::name =~ s,lib/?,,;
        $File::Find::name =~ s,/,::,g;
        push @modules, $File::Find::name;
    }, 'lib');

    open my $USE_OK, '>', 't/00-load.t' or die "Write 't/00-load.t': $!\n";

    print $USE_OK t_header();
    printf $USE_OK "plan tests => %i;\n", int @modules;

    for my $module (sort { $a cmp $b } @modules) {
        printf $USE_OK "use_ok('%s');\n", $module;
    }

    close $USE_OK;
}

__END__

=head1 NAME

dperl.pl - Helps maintaining your perl project

=head1 DESCRIPTION

dperl is a result of me getting tired of doing the same stuff - or
rather forgetting to do the same stuff for each of my perl projects.
dperl does not feature the same things as Dist::Zilla, but I would
like to think of dperl VS dzil as CPAN  vs cpanm - or at least that
is what I'm aming for. (!) What I don't want to do, is to configure
anything, so 1) it just works 2) it might not work as you want it to.

=head1 SYNOPSIS

 dperl.pl [option]

 -update
  * Create/update t/00-load.t and t/99-pod*t
  * Create/update README

 -build
  * Same as -update
  * Update Changes with release date
  * Create Makefile.PL, MANIFEST and META.yml
  * Create a distribution (.tar.gz)

 -release
  * Will create a new git commit and tag

 -share (experimental)
  * Will upload the disted file to CPAN
  * Will push commit and tag to "origin"

 -test
  * Will test the project

 -clean
  * Will remove files and directories

 -dperl.yml
  * Prints an example dperl.yml config file

=head1 SAMPLE dperl.yml

  ---
  # http://jhthorsen.github.com/snippets/dperl
  requires:
    namespace::autoclean: 0.09
    Data::Dumper: 2.0
  test_requires:
    Test::More: 0.9
  resources:
    bugtracker: http://rt.cpan.org/NoAuth/Bugs.html?Dist=Foo-Bar
    homepage: http://mary.github.com/foobar
    repository: http://github.com/mary/foo-bar

=cut


=head1 SEE ALSO

L<App::Cpanminus>,
L<Dist::Zilla>,
L<http://jhthorsen.github.com/snippets/dperl>.

=head1 BUGS

Report bugs and issues at L<http://github.com/jhthorsen/snippets/issues>.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jan Henning Thorsen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. 

=head1 AUTHOR

Jan Henning Thorsen, C<jhthorsen at cpan.org>

=cut
