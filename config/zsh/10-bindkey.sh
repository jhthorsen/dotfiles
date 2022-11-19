# Start out with vim
bindkey -v

# Also want some emacs keybindings
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line

function clear-scrollback-buffer {
  printf '\e[3J' && clear;
}

zle -N clear-scrollback-buffer
bindkey '^L' clear-scrollback-buffer
