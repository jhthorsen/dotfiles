bindkey '^[[Z' reverse-menu-complete

setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
unsetopt always_to_end

zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion
zstyle ':completion:*' special-dirs true

# Autocomplete caching
# zstyle ':completion:*' use-cache on
# zstyle ':completion:*' cache-path ~/.zsh/cache

# rm -f ~/.zcompdump; compinit

FZF_HOME=${FZF_HOME:-/usr/local/opt/fzf}
if [ -d $FZF_HOME ]; then
  if [[ ! "$PATH" == *$FZF_HOME/bin* ]]; then
    export PATH="${PATH:+${PATH}:}$FZF_HOME/bin"
  fi

  [[ $- == *i* ]] && source "$FZF_HOME/shell/completion.zsh" 2> /dev/null

  source "$FZF_HOME/shell/key-bindings.zsh"
fi

if command -v gopass >/dev/null; then
  GOPASS_COMPLETION_FILE=$HOME/.config/dot-files/gopass-completion.zsh
  gopass completion zsh > $GOPASS_COMPLETION_FILE
  fpath=($GOPASS_COMPLETION_FILE $fpath)
fi
