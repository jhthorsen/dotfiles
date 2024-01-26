#!/bin/bash
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias cpanm='cpanm -M https://cpan.metacpan.org'
alias ddp="PERL5OPT=-MDDP=caller_info,1,colored,1,use_prototypes,0"
alias doctl='doctl --access-token=$DO_API_TOKEN'
alias grep='grep --color=auto --line-buffered';
alias gti='git'
alias h="history -i -D"
alias hwinfo='dmidecode'
alias l='ls --color=auto --group-directories-first -F -h'
alias ll='l -l'
alias limited='ulimit -d 600000 -m 600000 -v 600000 -t 2 -u 5000; ulimit -a'
alias pass='stty sane && PASSWORD_STORE_ENABLE_EXTENSIONS=true pass'
alias pcover='perl Makefile.PL; cover -ignore_re="t/.*" -prefer_lib -test; make clean'
alias pipesha10='shasum | cut -c1-10'
alias reload='jobs | grep -q "[a-z]" && echo "Cannot reload zsh when there are running jobs." || exec zsh'
alias sort='LC_ALL=C sort'
alias tmpdir='perl -le"use File::Spec;print File::Spec->tmpdir"'
alias wttr='curl https://wttr.in/'

if [ "$(uname)" = "Linux" ]; then
  alias btrfs='sudo -i btrfs';
  alias docker='sudo docker';
  alias kubectl='sudo kubectl';
  alias nginx='sudo -i nginx';
  alias wo='sudo -i wo';
  alias wp='sudo -u www-data wp';
fi

command -v getcwd >/dev/null || alias getcwd='echo $PWD';
command -v launchctl >/dev/null && alias psql.start="launchctl load "$HOMEBREW_PREFIX/opt/postgresql/homebrew.mxcl.postgresql.plist"";
command -v rg >/dev/null && alias ack='rg';
