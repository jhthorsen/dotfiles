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

FZF_HOME=${FZF_HOME:-$HOMEBREW_PREFIX/opt/fzf};
if [ -d $FZF_HOME ]; then
  if [[ ! "$PATH" == *$FZF_HOME/bin* ]]; then
    export PATH="${PATH:+${PATH}:}$FZF_HOME/bin"
  fi

  [[ $- == *i* ]] && source "$FZF_HOME/shell/completion.zsh" 2> /dev/null
  source "$FZF_HOME/shell/key-bindings.zsh";
fi

# fedora
[ -r "/usr/share/fzf/shell/key-bindings.zsh" ] && source "/usr/share/fzf/shell/key-bindings.zsh";

# ubuntu
[ -r "/usr/share/doc/fzf/examples/completion.zsh" ] && source "/usr/share/doc/fzf/examples/completion.zsh";
[ -r "/usr/share/doc/fzf/examples/key-bindings.zsh" ] && source "/usr/share/doc/fzf/examples/key-bindings.zsh";

which rg &>/dev/null && export FZF_DEFAULT_COMMAND='rg --files';
