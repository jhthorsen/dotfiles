alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias cpanm='cpanm -M https://cpan.metacpan.org'
alias doctl='doctl --access-token=$DO_API_TOKEN'
alias gensecret='echo "$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 32)"'
alias gof='gopass show -c $(gopass list -f | fzf --no-mouse --preview "gopass show {} | tail -n +1")'
alias grep='grep --color=auto --line-buffered'
alias gti='git'
alias hwinfo='dmidecode'
alias limited='ulimit -d 600000 -m 600000 -v 600000 -t 2 -u 5000; ulimit -a'
alias pass='PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
alias pcover='perl Makefile.PL; cover -ignore_re="t/.*" -prefer_lib -test; make clean'
alias pipesha10='shasum | cut -c1-10'
alias reload='jobs | grep -q "[a-z]" && echo "Cannot reload zsh when there are running jobs." || exec zsh'
alias sort='LC_ALL=C sort'
alias tmpdir='perl -le"use File::Spec;print File::Spec->tmpdir"'
alias vi='vim'
alias vij='sshj edit'

command -v launchctl  >/dev/null && alias psql.start='launchctl load /usr/local/opt/postgresql/homebrew.mxcl.postgresql.plist'
command -v tmux       >/dev/null && alias tma='tmux attach-session -t'
command -v ack-grep   >/dev/null && alias ack='ack-grep'
command -v gopass     >/dev/null && alias gopass='LESS=rXx2 gopass'
