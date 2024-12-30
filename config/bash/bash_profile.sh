#!/bin/bash

_alias() { echo "alias $1='$2';"; }
_cmd() { echo "$*;"; }
_source() { echo "source \"$1\";"; }

_source "$HOME/.bashrc";
[ -e "$HOME/.bash_profile_local" ] && _source "$HOME/.bash_profile_local";

grep -v "^#" "$(dirname "${BASH_SOURCE[0]}")/bash_functions.sh";

command -v starship >/dev/null && _cmd 'eval "$(starship init bash)"';
echo "__user_starship_precmd() { history -a; }";
_cmd "starship_precmd_user_func=__user_starship_precmd";

_alias airport "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
_alias cpanm "cpanm -M https://cpan.metacpan.org"
_alias grep "grep --color=auto --line-buffered";
_alias gti "git";
_alias ll "eza --color=auto --time-style=long-iso --group-directories-first --classify";
_alias la "eza --color=auto --time-style=long-iso --group-directories-first --long --all";
_alias lt "eza --icons=auto --color=always --time-style=long-iso --long --no-quotes --sort time";
_alias l "eza --icons=auto --color=always --time-style=long-iso --long --no-quotes";
_alias pass "stty sane && PASSWORD_STORE_ENABLE_EXTENSIONS=true pass"
_alias pcover "perl Makefile.PL; cover -ignore_re="t/.*" -prefer_lib -test; make clean"
_alias psme "ps axfu | grep "$USER"";
_alias sort "LC_ALL=C sort";
_alias weather "curl https://wttr.in/"

command -v rg >/dev/null && _alias ack rg;

[ -e "/etc/profile.d/bash_completion.sh" ] && _source "/etc/profile.d/bash_completion.sh";
[ -e "/opt/homebrew/etc/profile.d/bash_completion.sh" ] && _source "/opt/homebrew/etc/profile.d/bash_completion.sh";
[ -d "$HOME/.config/shell" ] || mkdir -p "$HOME/.config/shell";

if command -v atuin >/dev/null; then
  _cmd 'eval "$(atuin init bash --disable-up-arrow)"';
else
  [ -r "$HOME/.config/shell/fzf-key-bindings.bash" ] \
    || curl -Ls "https://github.com/junegunn/fzf/raw/master/shell/key-bindings.bash" > "$HOME/.config/shell/fzf-key-bindings.bash";
  [ -r "$HOME/.config/shell/fzf-completion.bash" ] \
    || curl -Ls "https://github.com/junegunn/fzf/raw/master/shell/completion.bash" > "$HOME/.config/shell/fzf-completion.bash";
  _source "$HOME/.config/shell/fzf-completion.bash";
  _source "$HOME/.config/shell/fzf-key-bindings.bash";
fi

_cmd "complete -F __git_wrap__git_main gti";
_cmd "bind -m vi-command '\"\C-l\": clear-screen'";
_cmd "bind -m vi-insert  '\"\C-l\": clear-screen'";
_cmd "bind -m vi-insert  '\"\C-a\": beginning-of-line'";
_cmd "bind -m vi-insert  '\"\C-e\": end-of-line'";
_cmd "shopt -s histappend";
_cmd "shopt -s progcomp";
_cmd "shopt -s progcomp_alias";
_cmd "set -o vi";
_cmd "stty -echoctl";
