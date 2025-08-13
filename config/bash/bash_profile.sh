source "$HOME/.bashrc";

[ "$DOTFILES_HOME/config/bash/bashrc.sh" -nt "$HOME/.bashrc" ] && reload;
[ "$DOTFILES_HOME/config/bash/bash_profile.sh" -nt "$HOME/.bash_profile" ] && reload;

# inline
[ -f "$HOMEBREW_PREFIX/etc/profile.d/bash-preexec.sh" ] && source "$HOMEBREW_PREFIX/etc/profile.d/bash-preexec.sh";
[ -f "$HOME/.config/shell/fzf-completion.bash" ] && source "$HOME/.config/shell/fzf-completion.bash";
[ -f "$HOME/.config/shell/fzf-key-bindings.bash" ] && source "$HOME/.config/shell/fzf-key-bindings.bash";

alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias cpanm='cpanm -M https://cpan.metacpan.org'
alias grep='grep --color=auto --line-buffered';
alias gti='git';
alias pass='stty sane && PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
alias psme='ps axfu | grep "$USER"';
alias sort='LC_ALL=C sort';
alias weather='curl https://wttr.in/'

# inline
command -v eza >/dev/null && alias ll='eza --color=auto --time-style=long-iso --group-directories-first --classify';
command -v eza >/dev/null && alias la='eza --color=auto --time-style=long-iso --group-directories-first --long --all';
command -v eza >/dev/null && alias lt='eza --icons=auto --color=always --time-style=long-iso --long --no-quotes --sort time';
command -v eza >/dev/null && alias l='eza --icons=auto --color=always --time-style=long-iso --long --no-quotes';

complete -F __git_wrap__git_main gti;

bind -m vi-command '\"\C-l\": clear-screen';
bind -m vi-insert  '\"\C-l\": clear-screen';
bind -m vi-insert  '\"\C-a\": beginning-of-line';
bind -m vi-insert  '\"\C-e\": end-of-line';
shopt -s histappend;
shopt -s progcomp;
shopt -s progcomp_alias;
set -o vi;
stty -echoctl;

[ -e "$HOME/.bash_profile_local" ] && source "$HOME/.bash_profile_local";

# inline
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)";
command -v oh-my-posh >/dev/null && eval "$(oh-my-posh init bash --config $XDG_CONFIG_DIR/oh-my-posh.json)";

export PROMPT_COMMAND="history -a;$PROMPT_COMMAND";
