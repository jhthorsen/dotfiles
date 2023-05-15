# Generic
export ANSIBLE_NOCOWS="1";
export AUTO_REMOVE_SLASH="0";
export EDITOR="vi";
export FZF_DEFAULT_OPTS="--height 10 --reverse";
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";
export LESS="XFR";
export LS_COLORS="";
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD="true";
export TT_HOURS_PER_MONTH="150";
export UNAME="$(uname)";

# gpg
export GPG_TTY="$(tty)";
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)";
gpgconf --launch gpg-agent;

# Colors for man
export LESS_TERMCAP_mb="$(tput blink)";
export LESS_TERMCAP_md="$(tput bold; tput setaf 4)";
export LESS_TERMCAP_me="$(tput sgr0)";
export LESS_TERMCAP_se="$(tput rmso)";
export LESS_TERMCAP_so="$(tput smso)";
export LESS_TERMCAP_ue="$(tput sgr0)";
export LESS_TERMCAP_us="$(tput setaf 2)";

# For bin/vi
[ -x "/usr/bin/nvim" ] && export VIM_BIN="/usr/bin/nvim";
[ -x "/usr/local/bin/nvim" ] && export VIM_BIN="/usr/local/bin/nvim";
[ -x "$HOMEBREW_PREFIX/bin/nvim" ] && export VIM_BIN="$HOMEBREW_PREFIX/bin/nvim";
[ -x "$HOMEBREW_PREFIX/bin/hx" ] && export VIM_BIN="$HOMEBREW_PREFIX/bin/hx";

if command -v fd >/dev/null; then
  export FZF_CTRL_T_COMMAND="fd --type f";
  export FZF_DEFAULT_COMMAND="fd --type f";
fi
