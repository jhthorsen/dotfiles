#!/bin/zsh

function abort() {
  echo "! $*" >&2
  exit 1;
}

function pkg() {
  local name="$1"; [ -n "$1" ] && shift;
  local file="$1"; [ -n "$1" ] && shift;
  [ -z "$file" ] && file="$HOMEBREW_PREFIX/Cellar/$name";
  [ -e "$file" ] || file="$(which "$name")";
  if [ -e "$file" ]; then
    echo "run> $BREW_BIN install" "$@" "$name" >&2
  else
    run $BREW_BIN install "$@" "$name";
  fi
}

function run() {
  echo "run> $*" >&2
  [ "x$DRY_RUN" = "x" ] && $*;
}

[ -z "$HOMEBREW_PREFIX" ] && abort "HOMEBREW_PREFIX=/opt/homebrew missing";
BREW_BIN="$HOMEBREW_PREFIX/bin/brew";
[ ! -x "$BREW_BIN" ] && run ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";

run $BREW_BIN tap amar1729/formulae;
run $BREW_BIN tap remko/age-plugin-se https://github.com/remko/age-plugin-se;
run $BREW_BIN tap wez/wezterm;
run $BREW_BIN update && run $BREW_BIN upgrade;

# https://github.com/biox/pa
pkg age
pkg age-plugin-se
pkg age-plugin-yubikey
pkg wez/wezterm/wezterm /opt/homebrew/bin/wezterm --cask
pkg age
pkg age-plugin-se
pkg age-plugin-yubikey
pkg alt-tab /Applications/AltTab.app
pkg bat
pkg browserpass
pkg cloc
pkg coreutils
pkg cowsay
pkg cpanm
pkg csvprintf
pkg ctags
pkg doctl
pkg exiftool
pkg fd
pkg ffmpeg
pkg figlet
pkg fontconfig
pkg freetype
pkg fsevents-tools
pkg fx
pkg fzf
pkg geoip
pkg gh
pkg git
pkg glances
pkg gnupg
pkg gnutls
pkg go
pkg groff
pkg hopenpgp-tools
pkg imagemagick
pkg jpeg
pkg jpegoptim
pkg less
pkg lf
pkg lynx
pkg mkcert
pkg mysql
pkg mysql-client
pkg neovim
pkg nginx
pkg nmap
pkg node
pkg openssh
pkg openssl
pkg pass
pkg perl
pkg pinentry
pkg pinentry-mac
pkg pngcrush
pkg postgresql
pkg procs
pkg psgrep
pkg python
pkg qrencode
pkg redis
pkg rename
pkg rg
pkg rmlint
pkg rsync
pkg ruby
pkg rust
pkg smartmontools
pkg sqlite
pkg ssh-copy-id
pkg sshuttle
pkg telnet
pkg tesseract
pkg trash-cli
pkg tree
pkg wget
pkg ykman
pkg yubikey-personalization /opt/homebrew/Cellar/ykpers
pkg z
pkg zsh
pkg zsh-completions
pkg zsh-git-prompt
pkg zsh-lovers
pkg zsh-syntax-highlighting

run cpanm -n App::errno
run cpanm -n App::githook_perltidy
run cpanm -n App::httpstatus
run cpanm -n App::pause
run cpanm -n App::podify
run cpanm -n App::tt
run cpanm -n CPAN::Uploader
run cpanm -n Devel::Cover
run cpanm -n Pod::Markdown
run cpanm -n Term::ReadKey

# run pip install osxphotos;

PREFIX='/opt/homebrew/opt/browserpass' make hosts-firefox-user -f '/opt/homebrew/opt/browserpass/lib/browserpass/Makefile';
run rm /usr/local/bin/githook-perltidy;
run ln -s "$(which githook-perltidy)" /usr/local/bin/githook-perltidy;

run curl -Ls https://github.com/biox/pa/raw/main/pa > /usr/local/bin/pa && chmod +x /usr/local/bin/pa;

run defaults write NSGlobalDomain InitialKeyRepeat -int 15
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
run defaults write com.apple.screencapture location $HOME/Downloads
run defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
run defaults write -g ApplePressAndHoldEnabled -bool false
# sudo killall SystemUIServer
# sudo killall -HUP mDNSResponder
