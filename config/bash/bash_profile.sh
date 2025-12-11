source "$HOME/.bashrc";

[ "$DOTFILES_HOME/config/bash/bashrc.sh" -nt "$HOME/.bashrc" ] && reload;
[ "$DOTFILES_HOME/config/bash/bash_profile.sh" -nt "$HOME/.bash_profile" ] && reload;

[ -f "$HOMEBREW_PREFIX/etc/profile.d/bash-preexec.sh" ] && source "$HOMEBREW_PREFIX/etc/profile.d/bash-preexec.sh"; # INLINE
[ -f "$HOME/.config/shell/fzf-completion.bash" ] && source "$HOME/.config/shell/fzf-completion.bash"; # INLINE
[ -f "$HOME/.config/shell/fzf-key-bindings.bash" ] && source "$HOME/.config/shell/fzf-key-bindings.bash"; # INLINE

alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias cpanm='cpanm -M https://cpan.metacpan.org'
alias grep='grep --color=auto --line-buffered';
alias gti='git';
alias pass='stty sane && PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
alias psme='ps axfu | grep "$USER"';
alias sort='LC_ALL=C sort';
alias weather='curl https://wttr.in/'

command -v eza >/dev/null && alias ll='eza --color=auto --time-style=long-iso --group-directories-first --classify'; # INLINE
command -v eza >/dev/null && alias la='eza --color=auto --time-style=long-iso --group-directories-first --long --all'; # INLINE
command -v eza >/dev/null && alias lt='eza --icons=auto --color=always --time-style=long-iso --long --no-quotes --sort time'; # INLINE
command -v eza >/dev/null && alias l='eza --icons=auto --color=always --time-style=long-iso --long --no-quotes'; # INLINE

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

command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)"; # INLINE
# read:generate_ps1

export PROMPT_COMMAND="history -a;$PROMPT_COMMAND";
