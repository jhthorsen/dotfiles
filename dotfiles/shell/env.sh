export ANSIBLE_NOCOWS=1
export EDITOR=vi
export GPG_TTY=$(tty)
export LESS=XFR;
export LS_COLORS=
export TT_HOURS_PER_MONTH=150
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

[ "$(uname)" = "Linux" ] && export GPG_TTY=$(tty)

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

# Fix ^M in some programs, such as gpg
[ "x$UNAME" = "xDarwin" ] && stty sane;
