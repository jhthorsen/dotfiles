#!/bin/bash

baseurl="https://raw.githubusercontent.com/neovim/nvim-lspconfig/refs/heads/master/lsp";
basedir="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")";

runx() {
  echo "\$ $*" >&2;
  "$@" || exit "$?";
}

while read -r line; do
  cmd="$(grep -o "sh:.*" <<< "$line" | sed 's/^sh:\s*//')";
  [ "$INSTALL" = "1" ] && runx $cmd;
  lsp="$(awk -F '[{}]' '{print $2}' <<< "$line" | sed 's/[" ]//g')";
  runx curl --no-progress-meter "$baseurl/$lsp.lua" > "lsp/$lsp.lua";
done < <(grep "^vim.lsp.enable" "$basedir/init.lua");
