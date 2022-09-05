use utf8;
use ExtUtils::MakeMaker;

my $GITHUB_URL = 'https://github.com/jhthorsen/${PROJECT_NAME_LC}';

my %WriteMakefileArgs = (
  AUTHOR        => 'Jan Henning Thorsen <jhthorsen@cpan.org>',
  LICENSE       => 'artistic_2',
  NAME          => '${MAIN_PM_NAME}',
  ABSTRACT_FROM => '${MAIN_PM_FILE}',
  VERSION_FROM  => '${MAIN_PM_FILE}',
  EXE_FILES     => [],
  TEST_REQUIRES => {'Test2::V0'   => '0.000145'},
  PREREQ_PM     => {'Mojolicious' => '9.00'},
  META_MERGE    => {
    'dynamic_config' => 0,
    'meta-spec'      => {version => 2},
    'resources'      => {
      bugtracker => {web => "$GITHUB_URL/issues"},
      homepage   => $GITHUB_URL,
      repository => {type => 'git', url => "$GITHUB_URL.git", web => $GITHUB_URL},
    },
    'x_contributors' => [],
  },
  test => {TESTS => (-e 'META.yml' ? 't/*.t' : 't/*.t xt/*.t')},
);

unless (eval { ExtUtils::MakeMaker->VERSION('6.63_03') }) {
  my $test_requires = delete $WriteMakefileArgs{TEST_REQUIRES};
  @{$WriteMakefileArgs{PREREQ_PM}}{keys %$test_requires} = values %$test_requires;
}

WriteMakefile(%WriteMakefileArgs);
