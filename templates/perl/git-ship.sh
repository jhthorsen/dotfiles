#!/bin/bash
project_is_ready() {
  grep 'Not Released' ./Changes && return 1;
  test -n "$(find ./ -maxdepth 1 -name "*.tar.gz")" || return 1;
  return 0;
}

prepare_project() {
  MAIN_PM_FILE="$(grep ABSTRACT_FROM Makefile.PL | cut -d\' -f 2 | head -n1)";
  NEXT_VERSION="$(grep 'Not Released' ./Changes | head -n1 | awk '{print $1}')";
  [ -z "$NEXT_VERSION" ] && usage 1 'Unable to find version from ./Changes';
  [ -e 'Makefile' ] && run make clean;
  [ -e 'MANIFEST' ] && run rm MANIFEST;
  for f in Changes.bak Makefile META.json META.yml; do [ -e "$f" ] && run rm "$f"; done
  run find ./lib -type f -name '*pm' -exec sed -i '' -e "s/our[ ].*\$VERSION[ ]*=.*/our \$VERSION = '$NEXT_VERSION';/" '{}' \;
  run sed -i '' -e "s/[ ]Not Released.*/ $RELEASE_DATE/" Changes;
  run pod2markdown "$MAIN_PM_FILE" > README.md;
}

build_project() {
  run perl Makefile.PL;
  run make all;
  run make manifest;
  run make dist;
  run git add Changes Makefile.PL README.md lib/;
  git_commit_maybe "Released $NEXT_VERSION";
  git show -s "refs/tags/v$NEXT_VERSION" &>/dev/null && run git tag -d "v$NEXT_VERSION";
  run git tag "v$NEXT_VERSION";
}

test_project() {
  run prove -b -j4;
}

ship_project() {
  run git push origin "$(git branch --show-current)";
  run git push origin --tags;
  run cpan-upload ./*.tar.gz;
  run make clean;
  run git clean -f -d;
  [ -e 'MANIFEST' ] && run rm MANIFEST;
}
