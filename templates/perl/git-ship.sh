#!/bin/bash

build_project() {
  runx perl Makefile.PL;
  runx make all;
  runx make manifest;
  runx make dist;
  runx git add Changes Makefile.PL README.md lib/;
  git_commit_maybe "Released $NEXT_VERSION";
  git show -s "refs/tags/v$NEXT_VERSION" &>/dev/null && runx git tag -d "v$NEXT_VERSION";
  runx git tag "v$NEXT_VERSION";
}

command_clean() {
  [ -e Makefile ] && runx make clean;
  runx rm -f *.bak *.old *.tar.gz MYMETA.*;
  runx git clean -f -d;
}

command_ship() {
  runx git push origin "$(git branch --show-current)";
  runx git push origin --tags;
  runx cpan-upload ./*.tar.gz;
  runx make clean;
  command_clean;
}

command_test() {
  runx prove -b -j4;
}

project_is_ready() {
  grep 'Not Released' ./Changes && return 1;
  test -n "$(find ./ -maxdepth 1 -name "*.tar.gz")" || return 1;
  return 0;
}

prepare_project() {
  MAIN_PM_FILE="$(grep ABSTRACT_FROM Makefile.PL | cut -d\' -f 2 | head -n1)";
  NEXT_VERSION="$(grep 'Not Released' ./Changes | head -n1 | awk '{print $1}')";
  [ -z "$NEXT_VERSION" ] && usage 1 'Unable to find version from ./Changes';
  [ -e 'Makefile' ] && runx make clean;
  [ -e 'MANIFEST' ] && runx rm MANIFEST;
  for f in Changes.bak Makefile META.json META.yml; do [ -e "$f" ] && runx rm "$f"; done
  runx find ./lib -type f -name '*pm' -exec sed -i '' -e "s/our[ ].*\$VERSION[ ]*=.*/our \$VERSION = '$NEXT_VERSION';/" '{}' \;
  runx sed -i '' -e "s/[ ]Not Released.*/ $RELEASE_DATE/" Changes;
  runx pod2markdown "$MAIN_PM_FILE" > README.md;
}

start_project() {
  MAIN_PM_FILE="$(perl -e'$_=shift;s!-!/!g;print "lib/$_.pm"' "$PROJECT_NAME")";
  MAIN_PM_NAME="$(perl -e'$_=shift;s!-!::!g;print' "$PROJECT_NAME")";

  runx sed -i '' -e "s!\${PROJECT_NAME}!$PROJECT_NAME!" ./Changes ./Makefile.PL \
    && runx sed -i '' -e "s!\${MAIN_PM_FILE}!$MAIN_PM_FILE!" ./Makefile.PL \
    && runx sed -i '' -e "s!\${MAIN_PM_NAME}!$MAIN_PM_NAME!" ./Makefile.PL \
    && runx sed -i '' -e "s!\${PROJECT_NAME_LC}!$PROJECT_NAME_LC!" ./Makefile.PL;

  # Have to commit .perltidyrc for githook-perltidy to run below
  runx git add .gitignore .perltidyrc MANIFEST.SKIP;
  git_commit_maybe "";

  [ -e '.git/hooks/pre-commit' ] || runx githook-perltidy install;
  [ -d "$(dirname "$MAIN_PM_FILE")" ] || runx mkdir -p "$(dirname "$MAIN_PM_FILE")";
  [ -e "$MAIN_PM_FILE" ] || echo -ne "package $MAIN_PM_NAME;\n\nour \$VERSION = '0.01';\n\n1;\n" > "$MAIN_PM_FILE";
  runx git add .github Changes Makefile.PL lib t;
}
