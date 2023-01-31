# Start out with vim
bindkey -v

# Also want some emacs keybindings
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line

function ctrl-l {
  echo;
  clean;
  zle && zle .reset-prompt && zle -R;
}

zle -N ctrl-l
bindkey '^L' ctrl-l
