export ANSIBLE_NOCOWS="1";
export EDITOR="vi";
export GPG_TTY="$(tty)";
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";
export LESS="XFR";
export LS_COLORS=
export TT_HOURS_PER_MONTH="150";

# colors for man
LESS_TERMCAP_mb="$(tput blink)"; export LESS_TERMCAP_mb;
LESS_TERMCAP_md="$(tput bold; tput setaf 4)"; export LESS_TERMCAP_md;
LESS_TERMCAP_me="$(tput sgr0)"; export LESS_TERMCAP_me;
LESS_TERMCAP_se="$(tput rmso)"; export LESS_TERMCAP_se;
LESS_TERMCAP_so="$(tput smso)"; export LESS_TERMCAP_so;
LESS_TERMCAP_ue="$(tput sgr0)"; export LESS_TERMCAP_ue;
LESS_TERMCAP_us="$(tput setaf 2)"; export LESS_TERMCAP_us;

[ -x "/usr/bin/nvim" ] && export VIM_BIN="/usr/bin/nvim"
[ -x "/usr/local/bin/nvim" ] && export VIM_BIN="/usr/local/bin/nvim"
[ -x "$HOMEBREW_PREFIX/bin/nvim" ] && export VIM_BIN="$HOMEBREW_PREFIX/bin/nvim"

if command -v fd >/dev/null; then
  export FZF_CTRL_T_COMMAND='fd --type f'
  export FZF_DEFAULT_COMMAND='fd --type f'
fi

if [ -z "$SSH_TTY" ]; then
  export BROWSER=google-chrome
  export FZF_DEFAULT_OPTS='--height 20 --reverse'
else
  export FZF_DEFAULT_OPTS='--height 10 --reverse'
fi
