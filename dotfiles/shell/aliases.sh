alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'
alias cpanm='cpanm -M https://cpan.metacpan.org'
alias doctl='doctl --access-token=$DO_API_TOKEN'
alias export-photos='osxphotos export ~/Pictures/raw --directory "{created.year}" --filename "{created.strftime,%Y-%m-%d-%H%M%S}_{uuid}" --exiftool  --jpeg-ext jpg --touch-file --update'
alias gensecret='echo "$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 32)"'
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
alias wttr='curl https://wttr.in/'

if [ "x$(uname)" = "xLinux" ]; then
  alias apt='sudo -i apt';
  alias btrfs='sudo -i btrfs';
  alias docker='sudo -i docker';
  alias nginx='sudo -i nginx';
  alias systemctl='sudo -i systemctl';
  alias wo='sudo -i wo';
  alias wp='sudo -u www-data wp';
fi

command -v launchctl  >/dev/null && alias psql.start="launchctl load $HOMEBREW_PREFIX/opt/postgresql/homebrew.mxcl.postgresql.plist"
command -v tmux       >/dev/null && alias tma='tmux attach-session -t'
command -v ack-grep   >/dev/null && alias ack='ack-grep'
