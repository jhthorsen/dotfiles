#!/bin/zsh
[ "x$1" = "x-x" ] || DRY_RUN=1;

# TODO
# - https://github.com/aristocratos/btop

function run() {
  echo "> $*";
  [ "x$DRY_RUN" = "x" ] && $*;
}

BREW_BIN="/usr/local/bin/brew";

if [ ! -x "$BREW_BIN" ]; then
  run ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)";
  UPDATE=1;
fi

if [ "x$UPDATE" = "x1" ]; then
  run arch -x86_64 $BREW_BIN update;
fi

run arch -x86_64 $BREW_BIN install                         \
  ack             browserpass              cloc            \
  coreutils       cowsay                   cpanm           \
  csvprintf       ctags                    diff-so-fancy   \
  docker          docker-compose           doctl           \
  exiftool        fd                       ffmpeg          \
  figlet          fontconfig               freetype        \
  fzf             gh                       geoip           \
  git             git-secret               glances         \
  gnupg           gnutls                   go              \
  gopass          imagemagick              ircd-hybrid     \
  jpeg            jpegoptim                kubernetes-cli  \
  less            mkcert                   mysql           \
  mysql-client    nginx                    nmap            \
  node            neovim                   openssl         \
  perl            pinentry                 pngcrush        \
  postgresql      psgrep                   pstree          \
  python          redis                    rename          \
  ruby            rust                     sqlite          \
  smartmontools                                            \
  ssh-copy-id     sshuttle                 telnet          \
  terraform       terraform-docs           tesseract       \
  tmux            tmuxinator-completion    tree            \
  vim             wget                     z               \
  zsh             zsh-completions          zsh-git-prompt  \
  zsh-lovers      zsh-syntax-highlighting                  \

run cpanm -n
  App::errno              App::git::ship   App::githook_perltidy  \
  App::githook::perltidy  App::httpstatus  App::pause             \
  App::podify             App::prowess     App::tt                \
  Devel::Cover                                                    \

run npm install -g pnpm;

run pip install osxphotos;

run rm /usr/local/bin/githook-perltidy;
run ln -s "$(which githook-perltidy)" /usr/local/bin/githook-perltidy;

run defaults write NSGlobalDomain InitialKeyRepeat -int 15
run defaults write NSGlobalDomain KeyRepeat -int 2
run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
run defaults write com.apple.screencapture location $HOME/Downloads
# run defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
# sudo killall SystemUIServer
# sudo killall -HUP mDNSResponder
