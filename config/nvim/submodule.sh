#!/bin/sh
[ "$1" = "update" ] && exec git submodule update --remote share/nvim/site/pack/batpack;

URL="$1";
NAME="$(basename "$URL")";
git submodule add "$URL" "share/nvim/site/pack/batpack/start/$NAME";
git commit .gitmodules share/nvim/site/pack/batpack -m "Add neovim plugin $NAME";
