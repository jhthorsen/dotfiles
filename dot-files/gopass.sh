if command -v gopass >/dev/null; then
  GOPASS_COMPLETION_FILE=$HOME/.config/dot-files/gopass-completion.zsh
  gopass completion zsh > $GOPASS_COMPLETION_FILE
  fpath=($GOPASS_COMPLETION_FILE $fpath)
fi
