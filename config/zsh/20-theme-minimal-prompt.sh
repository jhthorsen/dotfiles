# magenta, red, white, yellow, black, blue, cyan, green
autoload -U colors && colors;

export PROMPT_MINIMAL_PATH="";
export PROMPT_MINIMAL_SUFFIX="";
export PROMPT_MINIMAL_USERINFO="";

# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
function __prompt_minimal () {
  local SSH_COLOR="$fg[magenta]";
  if [ -d '.git' ]; then
    export PROMPT_MINIMAL_SUFFIX=" ";
    local FILE_OWNER="$(stat --format '%U' '.git')";

    if [ "x$FILE_OWNER" = "x$USER" ]; then
      export PROMPT_MINIMAL_PATH="%{$fg[green]%}%1d%{$reset_color%}";
    else
      export PROMPT_MINIMAL_PATH="%{$fg[red]%}~$FILE_OWNER:%1d%{$reset_color%}";
      SSH_COLOR="$fg[red]";
    fi
  else
    export PROMPT_MINIMAL_PATH="%{$fg[green]%}%(4~|.../%3~|%~)%{$reset_color%}";
    export PROMPT_MINIMAL_SUFFIX=" ";
  fi

  PROMPT_MINIMAL_USERINFO="";
  if [ "x$USER" = "x$ORIGINAL_USER" ]; then                     # original login user
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then          # connnected over ssh
      PROMPT_MINIMAL_USERINFO="%{$SSH_COLOR%}%m%{$reset_color%} ";
    fi
  else                                                          # changed user
    PROMPT_MINIMAL_USERINFO="%{$fg[red]%}%n@%m%{$reset_color%} ";
  fi
}

if autoload -Uz is-at-least && ! is-at-least 5.1; then
  export ORIGINAL_USER=${ORIGINAL_USER:-$USER};
  autoload -U add-zsh-hook;
  add-zsh-hook chpwd __prompt_minimal;
  add-zsh-hook precmd __prompt_minimal;
  __prompt_minimal;

  export PS1="$PROMPT_MINIMAL_USERINFO$PROMPT_MINIMAL_PATH$PROMPT_MINIMAL_SUFFIX";
fi
