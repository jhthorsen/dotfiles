# Requires https://github.com/olivierverdier/zsh-git-prompt
export ZSH_THEME_GIT_PROMPT_CACHE=1;
ZSH_GIT_PROMPT_HOME=${ZSH_GIT_PROMPT_HOME:-$HOME/.config/dot-files/zsh-git-prompt};
source $ZSH_GIT_PROMPT_HOME/zshrc.sh;

# magenta, red, white, yellow, black, blue, cyan, green
autoload -U colors && colors;

export PROMPT_BMIN_PATH="";
export PROMPT_BMIN_SUFFIX="";
export PROMPT_BMIN_USERINFO="";

# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
function __prompt_bmin () {
  if [ -d '.git' ]; then
    export PROMPT_BMIN_PATH="%{$fg[green]%}%1d%{$reset_color%}";
    export PROMPT_BMIN_SUFFIX="$(git_super_status) ";
  else
    export PROMPT_BMIN_PATH="%{$fg[green]%}%(4~|.../%3~|%~)%{$reset_color%}";
    export PROMPT_BMIN_SUFFIX=" ";
  fi

  PROMPT_BMIN_USERINFO="";
  if [ "x$USER" = "x$ORIGINAL_USER" ]; then                     # original login user
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then          # connnected over ssh
      PROMPT_BMIN_USERINFO="%{$fg[magenta]%}%m%{$reset_color%} ";
    fi
  else                                                          # changed user
    PROMPT_BMIN_USERINFO="%{$fg[red]%}%n@%m%{$reset_color%} ";
  fi
}

export ORIGINAL_USER=${ORIGINAL_USER:-$USER};
autoload -U add-zsh-hook;
add-zsh-hook chpwd __prompt_bmin;
add-zsh-hook precmd __prompt_bmin;
__prompt_bmin;

export PROMPT='$PROMPT_BMIN_USERINFO$PROMPT_BMIN_PATH$PROMPT_BMIN_SUFFIX';
