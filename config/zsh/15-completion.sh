function dotfiles_precmd_function__bindkey_init() {
  precmd_functions=(${precmd_functions:#_dotfiles_bindkey_init});

  # fedora
  [ -r "/usr/share/fzf/shell/key-bindings.zsh" ] && source "/usr/share/fzf/shell/key-bindings.zsh";

  # homebrew
  FZF_HOME=${FZF_HOME:-$HOMEBREW_PREFIX/opt/fzf};
  if [ -d "$FZF_HOME" ]; then
    [[ ! "$PATH" == *$FZF_HOME/bin* ]] && export PATH="${PATH:+${PATH}:}$FZF_HOME/bin";
    [[ "$-" == *i* ]] && source "$FZF_HOME/shell/completion.zsh" 2> /dev/null
    source "$FZF_HOME/shell/key-bindings.zsh";
  fi

  zvm_define_widget dotfiles_fzf_history_widget;
  zvm_bindkey viins '^R' dotfiles_fzf_history_widget;
}

function dotfiles_fzf_history_widget() {
  fzf-history-widget "$@";
  zle .reset-prompt;
}

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

# ubuntu
[ -r "/usr/share/doc/fzf/examples/completion.zsh" ] && source "/usr/share/doc/fzf/examples/completion.zsh";
[ -r "/usr/share/doc/fzf/examples/key-bindings.zsh" ] && source "/usr/share/doc/fzf/examples/key-bindings.zsh";

which rg &>/dev/null && export FZF_DEFAULT_COMMAND='rg --files';

precmd_functions+=(dotfiles_precmd_function__bindkey_init);
