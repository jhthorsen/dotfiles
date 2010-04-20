#!/usr/bin/perl

package dPerl;

use strict;
use warnings;
use Cwd;
use File::Basename;
use File::Find;
use YAML::Tiny;

my $version_re = qr/\d+ \. [\d_]+/x;
my $self = bless {}, __PACKAGE__; # singleton

# $hash = $self->config;
sub config {
    return $self->{'config'} ||= YAML::Tiny->read('dperl.yml') || [];
}

# $str = $self->share_extension
sub share_extension {
    return $self->{'share_extension'}
       ||= $ENV{'DPERL_SHARE_MODULE'}
       ||  $self->config->[0]{'share_extension'}
       ||  'CPAN::Uploader';
}

# $hash = $self->pause_info
sub pause_info {
    return $self->{'pause_info'} ||= $self->_build_pause_info;
}

sub _build_pause_info {
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

# $hash = $self->share_params;
sub share_params {
    return $self->config->[0]{'share_params'} if($self->config->[0]{'share_params'});
    return;
}

# returns the project name
# can be set in config: "name: foo-bar"
# example: foo-bar
sub name {
    return $self->{'name'}
       ||= $self->config->[0]{'name'}
       ||  $self->_build_name;
}

sub _build_name {
    my $name = join '-', split '/', $self->top_module;

    $name =~ s,^.?lib-,,;
    $name =~ s,\.pm$,,;

    return $name;
}

# returns the top module location
# example: lib/Foo/Bar.pm
sub top_module {
    return $self->{'top_module'}
       ||= $self->config->[0]{'top_module'}
       ||  $self->_build_top_module;
}

sub _build_top_module {
    my $name = $self->config->[0]{'name'} || basename getcwd;
    my @path = split /-/, $name;
    my $path = 'lib';
    my $file;

    $path[-1] .= ".pm";

    for my $p (@path) {
        opendir my $DH, $path or die "Cannot find top module from project name '$name': $!\n";
        for my $f (readdir $DH) {
            if(lc $f eq lc $p) {
                $path = "$path/$f";
                last;
            }
        }
    }
    
    unless(-f $path) {
        die "Cannot find top module from project name '$name': $path is not a plain file\n";
    }

    return $path;
}

sub top_module_name {
    return $self->{'top_module_name'}
       ||= $self->config->[0]{'top_module_name'}
       ||  $self->_filename_to_module($self->top_module);
}

sub changes {
    return $self->{'changes'} ||= $self->_build_changes;
}

sub _build_changes {
    my($latest, $version);

    open my $CHANGES, '<', 'Changes' or die "Read 'Changes': $!\n";

    while(<$CHANGES>) {
        if($latest) {
            if(/^$/) {
                last;
            }
            else {
                $latest .= $_;
            }
        }
        elsif(/^($version_re)\s+\w+.*$/) {
            $version = $1;
            $latest = $_;
        }
        elsif(/^($version_re)/) {
            die "Found version info, but no date. Changes need to be updated\n";
        }
    }

    unless($latest and $version) {
        die "Could not find commit message nor version info from Changes\n";
    }

    return {
        latest => $latest,
        version => $version,
    };
}

# $filename = $self->dist_file;
# will die if dist has not yet been built
sub dist_file {
    my $file = sprintf '%s-%s.tar.gz', $self->name, $self->changes->{'version'};
    die "Need to run with -build first\n" unless(-e $file);
    return $file;
}

# will commit with the text from Changes and create a tag
sub tag_and_commit {
    $self->vsystem(git => commit => -a => -m => $self->changes->{'latest'});
    $self->vsystem(git => tag => $self->changes->{'version'});
    return;
}

# Will push tag/branch to git origin
sub share_via_git {
    my $branch = (qx/git branch/ =~ /\* (.*)$/m)[0];

    chomp $branch;

    $self->vsystem(git => push => origin => $branch);
    $self->vsystem(git => push => '--tags' => 'origin');

    return 1;
}

# will use CPAN::Uploader to upload the dist to cpan
sub share_via_extension {
    my $file = $self->dist_file;
    my $share_extension = $self->share_extension;

    eval "use $share_extension; 1" or die "This feature requires $share_extension to be installed";

    unless(-e $file) {
        die "Need to run with -build first\n";
    }

    # might die...
    if($share_extension eq 'CPAN::Uploader') {
        my $pause = $self->pause_info;
        $share_extension->upload_file($file, {
            user => $pause->{'user'},
            password => $pause->{'password'},
        });
    }
    else {
        $share_extension->upload_file($file, $self->share_params);
    }

    return 1;
}

# will insert a timestamp in Changes on a line looking like this:
# ^\d+\.[\d_]+\s*$
sub timestamp_to_changes {
    my $date = qx/date/;
    my($changes, $pm);

    chomp $date;

    open my $CHANGES, '+<', 'Changes' or die "Read/write 'Changes': $!\n";
    { local $/; $changes = <$CHANGES> };

    if($changes =~ s/\n($version_re)\s*$/{ sprintf "\n%-7s  %s", $1, $date }/em) {
        seek $CHANGES, 0, 0;
        print $CHANGES $changes;
        print "Add timestamp '$date' to Changes\n";
        return 1;
    }
    else {
        die "Unable to update Changes with timestamp\n";
        return;
    }
}

# will update version in top module
sub update_version_info {
    my $top_module = $self->top_module;
    my $version = $self->changes->{'version'};
    my $pm;

    open my $PM, '+<', $top_module or die "Read/write '$top_module': $!\n";
    { local $/; $pm = <$PM> };
    $pm =~ s/=head1 VERSION.*?\n=/=head1 VERSION\n\n$version\n\n=/s;
    $pm =~ s/\$VERSION\s*=.*$/\$VERSION = '$version';/m;

    seek $PM, 0, 0;
    print $PM $pm;

    print "Update version in '$top_module' to $version\n";

    return 1;
}

# will generate the README file
sub generate_readme {
    $self->vsystem(sprintf '%s %s > %s', 'perldoc -tT', $self->top_module, 'README');
    return 1;
}

# will remove any files which should not be part of the repo
sub clean {
    my $name = $self->name;
    $self->vsystem('make clean 2>/dev/null');
    $self->vsystem(sprintf 'rm -r %s 2>/dev/null', join(' ',
        "$name*",
        qw(
            blib/
            inc/
            Makefile
            Makefile.old
            MANIFEST*
            META.yml
        ),
    ));

    return 1;
}

# will create MANIFEST and MANIFEST.SKIP
sub manifest {
    $self->make('manifest') and die "Execute 'make manifest' failed\n";

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
                       ), $self->name;

    return 1;
}

# will create a Makefile.PL, unless it already exists
sub makefile {
    my $makefile = 'Makefile.PL';
    my $name = $self->name;
    my(%requires, $repo);

    die "$makefile already exist\n" if(-e $makefile);

    open my $MAKEFILE, '>', $makefile or die "Write '$makefile': $!\n";

    printf $MAKEFILE "use inc::Module::Install;\n\n";
    printf $MAKEFILE "name q(%s);\n", $self->name;
    printf $MAKEFILE "all_from q(%s);\n", $self->top_module;

    if(%requires = $self->find_requires('lib')) {
        print $MAKEFILE "\n";
    }
    for my $name (sort keys %requires) {
        printf $MAKEFILE "requires q(%s) => %s;\n", $name, $requires{$name};
    }

    if(%requires = $self->find_requires('t')) {
        print $MAKEFILE "\n";
    }
    for my $name (sort keys %requires) {
        printf $MAKEFILE "test_requires q(%s) => %s;\n", $name, $requires{$name};
    }

    $repo = (qx/git remote show -n origin/ =~ /URL: (.*)$/m)[0] || 'git://github.com/';
    $repo =~ s#^[^:]+:#git://github.com/#;

    print $MAKEFILE "\n";
    print $MAKEFILE "bugtracker q(http://rt.cpan.org/NoAuth/Bugs.html?Dist=$name);\n";
    print $MAKEFILE "homepage q(http://search.cpan.org/dist/$name);\n";
    print $MAKEFILE "repository q($repo);\n";
    print $MAKEFILE "\n";
    print $MAKEFILE "auto_install;\n";
    print $MAKEFILE "WriteAll;\n";
    
    print "Wrote Makefile.PL\n";

    return 1;
}

# will load the modules and build a list of modules they require
sub find_requires {
    my $self = shift;
    my $dir = shift or return;
    my $top_module_name = $self->top_module_name;
    my(%requires, %skip);

    eval 'package EVAL;
        no warnings "redefine";
        our @requires;
        sub _use { push @requires, @_ }
        sub _require { push @requires, @_ }
        sub _base { push @requires, @_ }
        sub _extends { push @requires, @_ }
        sub _with { push @requires, @_ }
        1;
    ' or die $@;

    finddepth(sub {
        return unless(-f $_);
        open my $FH, '<', $_ or return;
        while(<$FH>) {
            if(/^\s*package \s (\S+) .* ;/x) {
                $skip{$1}++;
                next;
            }

            local @EVAL::requires = ();

            if(/^\s*use \s ([A-Z]\S+)/x) {
                eval "package EVAL; _use('$1');" or warn "$1 => $@";
            }
            elsif(/^\s*require \s ([A-Z]\S+)/x) {
                eval "package EVAL; _require('$1');" or warn "$1 => $@";
            }
            elsif(/^\s*use \s (base .*)/x) {
                eval "package EVAL; _$1;" or warn "$1 => $@";
            }
            elsif(/^\s*(extends [\(\s] .*)/x) {
                eval "package EVAL; _$1;" or warn "$1 => $@";
            }
            elsif(/^\s*(with [\(\s] .*)/x) {
                eval "package EVAL; _$1;" or warn "$1 => $@";
            }

            $self->_require_version_and_name($_, \%requires) for @EVAL::requires;
        }
    }, $dir);

    delete $requires{$_} for keys %skip;

    return %requires if(wantarray);
    return \%requires;
}

sub _require_version_and_name {
    my $module = $_[1];
    my $req = $_[2];
    my($name, $version);

    $module =~ s/[^\w:]//;
    $name = $module;

    while($name) {
        # load module to get version number :S
        if(eval "use $name (); 1") {
            no warnings;
            $version = eval "\$$name\::VERSION" and last;
        }
        $name =~ s/:*\w+$// or last;
    }

    $req->{$name} = $version || 0 if$name;
}

sub _filename_to_module {
    local $_ = $_[1];
    s,\.pm,,;
    s,^/?lib/,,g;
    s,/,::,g;
    return $_;
}

sub make {
    $self->makefile unless(-e 'Makefile.PL');
    $self->vsystem('perl Makefile.PL') unless(-e 'Makefile');
    $self->vsystem(make => $_[1]);
}

sub t_pod {
    open my $POD_COVERAGE, '>', 't/99-pod-coverage.t' or die "Write 't/99-pod-coverage.t': $!\n";
    print $POD_COVERAGE $self->_t_header;
    print $POD_COVERAGE <<'TEST';
eval 'use Test::Pod::Coverage; 1' or plan skip_all => 'Test::Pod::Coverage required';
all_pod_coverage_ok();
TEST

    print "Wrote t/99-pod-coverage.t\n";

    open my $POD, '>', 't/99-pod.t' or die "Write 't/99-pod.t': $!\n";
    print $POD $self->_t_header;
    print $POD <<'TEST';
eval 'use Test::Pod; 1' or plan skip_all => 'Test::Pod required';
all_pod_files_ok();
TEST

    print "Wrote t/99-pod.t\n";

    return 1;
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

    print $USE_OK $self->_t_header;
    printf $USE_OK "plan tests => %i;\n", int @modules;

    for my $module (sort { $a cmp $b } @modules) {
        printf $USE_OK "use_ok('%s');\n", $module;
    }

    print "Wrote t/00-load.t\n";

    return 1;
}

sub _t_header {
    return <<'HEADER';
#!/usr/bin/perl
use lib qw(lib);
use Test::More;
HEADER
}

# will print what system() will run, before running it
sub vsystem {
    shift; # shift off class/object
    print "\$ @_\n";
    system @_;
}

# prints a help text
# this message needs to be duped from POD since parsing POD
# is no good when running this over a pipe: 'wget ... | perl -'
sub help {
    print <<"HELP";
Usage dperl.pl [option]

 -update
  * Update version information in main module
  * Create/update t/00-load.t and t/99-pod*t
  * Create/update README

 -build
  * Same as -update
  * Update Changes with release date
  * Create MANIFEST* and META.yml
  * Tag and commit the changes (locally)
  * Build a distribution (.tar.gz)

 -share
  * Push commit and tag to "origin"
  * Upload the disted file to CPAN

 -test
  * Create/update t/00-load.t and t/99-pod*t
  * Test the project

 -clean
  * Remove files and directories which should not be included
    in the project repo

 -makefile
  * Create a Makefile.PL from plain guesswork

 -man
  * Display manual for dperl.pl

HELP

    return 0;
}

#==============================================================================
package main;

use strict;
use warnings;
use Data::Dumper;

my $action = shift @ARGV or exit dPerl->help;
my $method = $action;

$action =~ s/^-+//;
$method =~ s/^-+//;
$method =~ s/-/_/g;

if($action =~ /update/) {
    dPerl->clean;
    dPerl->update_version_info;
    dPerl->t_compile;
    dPerl->t_pod;
    dPerl->generate_readme;
}
elsif($action =~ /build/) {
    dPerl->clean;
    dPerl->t_compile;
    dPerl->t_pod;
    dPerl->timestamp_to_changes;
    dPerl->update_version_info;
    dPerl->generate_readme;
    dPerl->manifest;
    dPerl->vsystem('rm ' .$self->name .'* 2>/dev/null');
    dPerl->tag_and_commit;
    dPerl->make('dist');
}
elsif($action =~ /test/) {
    dPerl->clean;
    dPerl->t_compile;
    dPerl->t_pod;
    dPerl->make('test');
}
elsif($action =~ /share(?!-)/) {
    dPerl->share_via_extension;
    dPerl->share_via_git;
}
elsif(dPerl->can($method)) {
    if(my $res = dPerl->$method(@ARGV)) {
        if(ref $res) {
            local $Data::Dumper::Indent = 1;
            local $Data::Dumper::Sortkeys = 1;
            local $Data::Dumper::Terse = 1;
            print Dumper $res;
        }
        elsif($res eq '1') {
            exit 0;
        }
        else {
            print $res, "\n";
        }
    }
    else {
        die "Failed to execute dPerl->$method\n";
    }
}
elsif($action =~ /man/) {
    if($0 eq '-') {
        print "Read manual online: http://jhthorsen.github.com/snippets/dperl\n"
    }
    else {
        exec perldoc => $0;
    }
}
else {
    dPerl->help;
    exit 1;
}

exit 0;

#=============================================================================
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

 Usage dperl.pl [option]

 -update
  * Update version information in main module
  * Create/update t/00-load.t and t/99-pod*t
  * Create/update README

 -build
  * Same as -update
  * Update Changes with release date
  * Create MANIFEST* and META.yml
  * Tag and commit the changes (locally)
  * Build a distribution (.tar.gz)

 -share
  * Push commit and tag to "origin"
  * Upload the disted file to CPAN

 -test
  * Create/update t/00-load.t and t/99-pod*t
  * Test the project

 -clean
  * Remove files and directories which should not be included
    in the project repo

 -makefile
  * Create a Makefile.PL from plain guesswork

 -man
  * Display manual for dperl.pl

=head1 OTHER METHODS

Dump internal attributes: --config, --share-extension, --pause-info, --share-params,
--name, --top-module, --top-module-name, --changes, --dist-file.

Run internal steps: --tag-and-commit, --share-via-git, --share-via-extension,
--timestamp-to-changes, --update-version-info, --generate-readme, --manifest,
--find-requires, --make.

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
