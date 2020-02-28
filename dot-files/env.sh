ANSIBLE_NOCOWS=1
EDITOR=vim
GPG_TTY=$(tty)
LESS="XFR";
LS_COLORS=
SSH_KEY_PATH="~/.ssh/id_rsa"
TT_HOURS_PER_MONTH=120

if command -v fd >/dev/null; then
  FZF_CTRL_T_COMMAND='fd --type f'
  FZF_DEFAULT_COMMAND='fd --type f'
fi

if [ -z "$SSH_TTY" ]; then
  BROWSER=google-chrome
  FZF_DEFAULT_OPTS='--height 20 --reverse'
else
  FZF_DEFAULT_OPTS='--height 10 --reverse'
  LANG=en_US.UTF-8
  LC_ALL=en_US.UTF-8
fi
