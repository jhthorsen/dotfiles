#!/bin/sh

if [ "$1" = "remove" ]; then
  [ -d "$2" ] || exec echo "Usage: $1 remove share/..."
  git submodule deinit -f "$2" || exit "$?";
  rm -r "$2" || exit "$2";
  exit;

elif [ "$1" = "update" ]; then
  git submodule update --remote share/nvim/site/pack/batpack || exit "$?";
  exit;

elif [ -n "$1" ]; then
  URL="$1";
  NAME="$(basename "$URL")";
  git submodule add "$URL" "share/nvim/site/pack/batpack/start/$NAME";
  git commit .gitmodules share/nvim/site/pack/batpack -m "Add neovim plugin $NAME";
fi
