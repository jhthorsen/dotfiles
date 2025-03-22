#!/bin/bash

_cmd() { echo "$*;"; }
_export() { export "$1=$2"; echo "export $1=\"$2\";"; }
_source() { echo "source \"$1\";"; }

echo "# Generated by $0";
HOMEBREW_PREFIX="$(/opt/homebrew/bin/brew --prefix 2>/dev/null)";
[ -n "$HOMEBREW_PREFIX" ] && _export HOMEBREW_PREFIX "$HOMEBREW_PREFIX";

_export ANSIBLE_NOCOWS "1";
_export AUTO_REMOVE_SLASH "0";
_export CDPATH ":$HOME/git:$HOME/git/_alien:$HOME/git/_old:$HOME/Nextcloud";
_export DOTFILES_HOME "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")";
_export EDITOR "nvim";
_export FZF_DEFAULT_COMMAND "fd --type f";
_export FZF_DEFAULT_OPTS "--height 10 --reverse";
_export HISTSIZE "10000";
_export LANG "en_US.UTF-8";
_export LESS "XFR";
_export LS_COLORS "";
_export NVIM_TERMINAL_SHELL "tmac";
_export SSLMAKER_HOME "/opt/homebrew/etc/sslmaker";
_export TT_HOURS_PER_MONTH "150";

[ -n "$SSH_TTY" ] && _export SNIPCLIP_HOSTNAME "127.0.0.1";
_export SNIPCLIP_PORT "38888"

command -v xcode-select >/dev/null && PATH="$(xcode-select --print-path)/usr/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/gettext/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/ncurses/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/openssl/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/go/libexec/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/python/libexec/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/lib/ruby/gems/3.3.0/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/perl/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/bin:$PATH";
[ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/sbin:$PATH";
[ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH";
[ -d "$HOME/.atuin/bin" ] && PATH="$HOME/.atuin/bin:$PATH";
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH";

PATH="$DOTFILES_HOME/bin:$PATH";
PATH="$(perl -e 'print join ":",grep{!$u{$_}++&&-e&&length}split ":",$ENV{PATH}')";
_export PATH "$PATH";

if command -v gpgconf >/dev/null; then
  _export GPG_TTY '$(tty)';
  _export SSH_AUTH_SOCK "$(gpgconf --list-dirs agent-ssh-socket)";
  _cmd "(&>/dev/null gpgconf --launch gpg-agent &)";
fi

[ -f "/opt/homebrew/etc/profile.d/bash-preexec.sh" ] \
  && _source "/opt/homebrew/etc/profile.d/bash-preexec.sh";
