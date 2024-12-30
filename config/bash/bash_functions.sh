#!/bin/bash
git() {
  if [ -z "$*" ]; then command git status -bs; return "$?"; fi
  if [ ! -t 0 ]; then command git "$@"; return "$?"; fi
  if ! command -v diffu >/dev/null; then command git "$@"; return "$?"; fi
  PAGER="diffu" command git "$@";
}

reload() {
  "$DOTFILES_HOME/config/bash/bash_profile.sh" > "$HOME/.bash_profile";
  "$DOTFILES_HOME/config/bash/bashrc.sh" > "$HOME/.bashrc";
  exec "$0" --rcfile "$DOTFILES_HOME/config/bash/bash_reload";
}
