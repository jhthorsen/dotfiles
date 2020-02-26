alias cpanm="cpanm -M https://cpan.metacpan.org";
alias ff="find . -type f | grep -v 'git\|.nuxt\|node_mo\|packed\|sass-cache\|\.swp' | sort"
alias gensecret='echo "$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 32)"'
alias gopass="LESS=rXx2 gopass"
alias gti="git"
alias limited="ulimit -d 600000 -m 600000 -v 600000 -t 2 -u 5000; ulimit -a"
alias pcover="perl Makefile.PL; cover -ignore_re='t/.*' -prefer_lib -test; make clean"
alias pipesha10="shasum | cut -c1-10"
alias psme="pstree -u jhthorsen -w"
alias psql.start="launchctl load /usr/local/opt/postgresql/homebrew.mxcl.postgresql.plist"
alias tma="tmux attach-session"
alias tmpdir="perl -le'use File::Spec;print File::Spec->tmpdir'"
alias vi="vim"
alias view="vim -R"

which ack-grep >/dev/null && alias ack="ack-grep"
