function ctrl-l {
  echo;
  clean;
  zle && zle .reset-prompt && zle -R;
}

zle -N ctrl-l
bindkey '^L' ctrl-l
