#!/bin/zsh

function abort() {
  echo "! $*" >&2;
  exit 1;
}

function run() {
  echo "> $*" >&2;
  [ "x$DRY_RUN" = "x" ] && $*;
}

[ -z "$HOMEBREW_PREFIX" ] && abort "HOMEBREW_PREFIX=/opt/homebrew missing";
BREW_BIN="$HOMEBREW_PREFIX/bin/brew";

if [ ! -x "$BREW_BIN" ]; then
  run ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
  UPDATE=1;
fi

#if [ "x$UPDATE" = "x1" ]; then
  #run arch -x86_64 $BREW_BIN update;
#fi

#run arch -x86_64 $BREW_BIN install                         \
run $BREW_BIN install ack
run $BREW_BIN install bat
run $BREW_BIN install browserpass
run $BREW_BIN install cloc
run $BREW_BIN install coreutils
run $BREW_BIN install cowsay
run $BREW_BIN install cpanm
run $BREW_BIN install csvprintf
run $BREW_BIN install ctags
run $BREW_BIN install diff-so-fancy
run $BREW_BIN install docker
run $BREW_BIN install docker-compose
run $BREW_BIN install doctl
run $BREW_BIN install exiftool
run $BREW_BIN install fd
run $BREW_BIN install ffmpeg
run $BREW_BIN install figlet
run $BREW_BIN install fontconfig
run $BREW_BIN install freetype
run $BREW_BIN install fsevents-tools
run $BREW_BIN install fzf
run $BREW_BIN install geoip
run $BREW_BIN install gh
run $BREW_BIN install git
run $BREW_BIN install git-secret
run $BREW_BIN install glances
run $BREW_BIN install gnupg
run $BREW_BIN install gnutls
run $BREW_BIN install go
run $BREW_BIN install gpg-suite
run $BREW_BIN install imagemagick
run $BREW_BIN install jpeg
run $BREW_BIN install jpegoptim
run $BREW_BIN install kubernetes-cli
run $BREW_BIN install less
run $BREW_BIN install lynx
run $BREW_BIN install mkcert
run $BREW_BIN install mysql
run $BREW_BIN install mysql-client
run $BREW_BIN install neovim
run $BREW_BIN install nginx
run $BREW_BIN install nmap
run $BREW_BIN install node
run $BREW_BIN install openssl
run $BREW_BIN install pass
run $BREW_BIN install perl
run $BREW_BIN install pinentry
run $BREW_BIN install pinentry-mac
run $BREW_BIN install pngcrush
run $BREW_BIN install postgresql
run $BREW_BIN install psgrep
run $BREW_BIN install pstree
run $BREW_BIN install python
run $BREW_BIN install qrencode
run $BREW_BIN install redis
run $BREW_BIN install rename
run $BREW_BIN install rg
run $BREW_BIN install rsync
run $BREW_BIN install ruby
run $BREW_BIN install rust
run $BREW_BIN install smartmontools
run $BREW_BIN install sqlite
run $BREW_BIN install ssh-copy-id
run $BREW_BIN install sshuttle
run $BREW_BIN install telnet
run $BREW_BIN install terraform
run $BREW_BIN install terraform-docs
run $BREW_BIN install tesseract
run $BREW_BIN install tmux
run $BREW_BIN install tmuxinator-completion
run $BREW_BIN install tree
run $BREW_BIN install vim
run $BREW_BIN install wget
run $BREW_BIN install z
run $BREW_BIN install zsh
run $BREW_BIN install zsh-completions
run $BREW_BIN install zsh-git-prompt
run $BREW_BIN install zsh-lovers
run $BREW_BIN install zsh-syntax-highlighting

# browserpass
run $BREW_BIN tap amar1729/formulae
run $BREW_BIN install browserpass;

run cd $HOMEBREW_PREFIX/opt/browserpass/lib/browserpass;
run make hosts-firefox-user;
run cd -;

run cpanm -n \
  App::errno              App::git::ship   App::githook_perltidy  \
  App::githook::perltidy  App::httpstatus  App::pause             \
  App::podify             App::prowess     App::tt                \
  Devel::Cover            PLS                                     ;

# run pip install osxphotos;

run rm /usr/local/bin/githook-perltidy;
run ln -s "$(which githook-perltidy)" /usr/local/bin/githook-perltidy;

run defaults write NSGlobalDomain InitialKeyRepeat -int 15
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
run defaults write com.apple.screencapture location $HOME/Downloads
run defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
# sudo killall SystemUIServer
# sudo killall -HUP mDNSResponder
