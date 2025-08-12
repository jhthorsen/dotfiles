#!/bin/bash
ack() {
  local -a args;
  local bin;

  bin="$(command -v rg)";
  if [ -n "$bin" ]; then
    while [ -n "$*" ]; do case "$1" in
      -L) args+=("--files-without-match"); shift ;;
      *) args+=("$1"); shift ;;
    esac done

    $DRY_RUN "$bin" "${args[@]}";
    return "$?";
  fi

  bin="$(command -v ack || command -v ack-grep)";
  if [ -n "$bin" ]; then
    $DRY_RUN "$bin" "$@";
    return "$?";
  fi

  # TODO Translate arguments to grep
  bin="grep";
  $DRY_RUN "$bin" "$@";
  return "$?";
}

acke() {
  vi $(ack -l "$@")
}

git() {
  if [ -z "$*" ]; then command git status -bs; return "$?"; fi
  if [ ! -t 0 ]; then command git "$@"; return "$?"; fi
  if ! command -v diffu >/dev/null; then command git "$@"; return "$?"; fi
  PAGER="diffu" command git "$@";
}

reload() {
  "$DOTFILES_HOME/config/bash/generate.sh" "$DOTFILES_HOME/config/bash/bashrc.sh" > "$HOME/.bashrc";
  "$DOTFILES_HOME/config/bash/generate.sh" "$DOTFILES_HOME/config/bash/bash_profile.sh" > "$HOME/.bash_profile";
  echo "Reloading bash v$BASH_VERSION";
  exec bash --login;
}

vi() {
  if [ -n "$*" ]; then nvim "$@";
  else nvim -c ':lua require("batphone.util").startup()';
  fi
}
