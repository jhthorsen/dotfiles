#!/bin/sh

GET_LANG="$1";
BASE_URL="http://ftp.vim.org/vim/runtime/spell";
DEST_DIR="$HOME/.config/nvim/spell";

get() {
  local rel="$1";
  local file="$HOME/.config/nvim/spell/$rel";
  local url="$BASE_URL/$rel";

  [ -d "$(dirname "$file")" ] || mkdir -p "$(dirname "$file")" || exit $?;

  echo "> Downloading $url ..." >&2;
  curl --fail-with-body -L -s "$url" -o "$file.tmp" \
    && mv "$file.tmp" "$file" \
    || echo "Unable to download $url to $file: $?";
}

get "en.utf-8.spl";
get "en.utf-8.sug";
get "en/main.aap";
get "en/en_GB.diff";
get "en/en_US.diff";

get "nb.utf-8.spl";
get "nb.utf-8.sug";
get "nb/main.aap";
get "nb/nb_NO.diff";
