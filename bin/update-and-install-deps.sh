#!/bin/bash
ROOT_DIR=$(pwd);

for i in *; do
  if [ -d "$i/.git" ]; then
    echo "";
    echo "--- $i";

    cd $i;
    git remote update;
    git pull;
    [ -e "cpanfile" -o -e "Makefile.PL" ] && cpanm -n --installdeps .
  fi

  cd $ROOT_DIR;
done
