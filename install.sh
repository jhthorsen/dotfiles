#!/bin/bash
XDG_CONFIG_DIR="$HOME/.config";
XDG_DATA_HOME="$HOME/.local/share";
DOTFILES="$(cd -- "$(dirname "$0")" >/dev/null ; pwd -P)";
[ -n "$HOMEBREW_PREFIX" ] && MAYBE_SUDO="" || MAYBE_SUDO="sudo";

function abort() {
  echo "! $*" >&2
  exit 1;
}

function and() {
  local x="$?";
  [ "$x" = "0" ] && echo "> $*" >&2 || echo "# $*" >&2;
  [ "$x" = "0" ] && "$@";
}

function lnk() {
  local from="$1";
  local to="$2";
  [ -L "$to" ] && [ ! -r "$to" ]; and rm "$to"; # Remove broken links
  [ ! -L "$to" ]; and ln -s "$from" "$to";
}

function install_brew() {
  [ -z "$HOMEBREW_PREFIX" ] && return 1;
  local brew="$HOMEBREW_PREFIX/bin/brew";
  [ ! -x "$brew" ] && abort "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"";

  true; and "$brew" tap amar1729/formulae;
  true; and "$brew" tap remko/age-plugin-se https://github.com/remko/age-plugin-se;
  [ -z "$SKIP_UPDATE" ]; and "$brew" update; and "$brew" upgrade;

  [ -e "/Applications/AltTab.app" ]; and "$brew" install alt-tab;
  [ -e "/opt/homebrew/Cellar/ykpers" ]; and "$brew" install yubikey-personalization;
  [ -e "/usr/local/bin/pa" ];
    and curl -Ls https://github.com/biox/pa/raw/main/pa > /usr/local/bin/pa;
    and chmod +x /usr/local/bin/pa;

  true; and "$brew" install \
    age            age-plugin-se age-plugin-yubikey bash-completion@2  \
    bat            browserpass   cloc               coreutils          \
    cowsay         cpanm         csvprintf          ctags              \
    doctl          exiftool      eza                fd                 \
    ffmpeg         figlet        fontconfig         freetype           \
    fsevents-tools fx            fzf                geoip              \
    gh             git           glances            gnupg              \
    gnutls         go            groff              hopenpgp-tools     \
    imagemagick    jpeg          jpegoptim          less               \
    lf             lynx          mkcert             mysql              \
    mysql-client   neovim        nginx              nmap               \
    node           openssh       openssl            pass               \
    perl           pinentry      pinentry-mac       pngcrush           \
    postgresql     procs         psgrep             python             \
    qrencode       redis         rename             rg                 \
    rmlint         rsync         ruby               rust               \
    smartmontools  sqlite        ssh-copy-id        sshuttle           \
    telnet         tesseract     trash-cli          tree               \
    wget           ykman         z;
}

function install_cpanm() {
  true; and "$MAYBE_SUDO" cpanm -n \
    App::errno  App::githook_perltidy App::httpstatus App::pause    \
    App::podify App::tt               CPAN::Uploader  Devel::Cover  \
    Mojolicious Pod::Markdown         Term::ReadKey;
}

function install_dotfiles() {
  # bash
  lnk "$DOTFILES/config/bash/inputrc" "$HOME/.inputrc";
  lnk "$DOTFILES/config/bash/bashrc" "$HOME/.bashrc";
  lnk "$DOTFILES/config/bash/bash_profile" "$HOME/.bash_profile";
  lnk "$DOTFILES/config/bash/bash_reload" "$HOME/.bash_reload";
  lnk "$DOTFILES/config/starship.toml" "$XDG_CONFIG_DIR/starship.toml";

  # nvim
  lnk "$DOTFILES/config/nvim" "$XDG_CONFIG_DIR/nvim";
  [ ! -d "$XDG_DATA_HOME/nvim/site/pack" ]; and mkdir -p "$XDG_DATA_HOME/nvim/site/pack"
  lnk "$DOTFILES/share/nvim/site/pack/batpack" "$XDG_DATA_HOME/nvim/site/pack/batpack";

  # misc
  lnk "$DOTFILES/config/ackrc" "$HOME/.ackrc";
  lnk "$DOTFILES/config/dataprinter" "$HOME/.dataprinter";
  lnk "$DOTFILES/config/git" "$XDG_CONFIG_DIR/git";
  lnk "$DOTFILES/config/lf" "$XDG_CONFIG_DIR/lf";
  lnk "$DOTFILES/config/perlcriticrc" "$HOME/.perlcriticrc";
  lnk "$DOTFILES/config/perltidyrc" "$HOME/.perltidyrc";
}

function install_misc() {
  # starship
  local arch; arch="$(arch)";
  local platform="unknown-linux-musl";
  [ "$(uname -o)" = "Darwin" ] && platform="apple-darwin";
  ! command -v starship > /dev/null; and curl -sL "https://github.com/starship/starship/releases/latest/download/starship-$arch-$platform.tar.gz" | tar xz -C "$PWD/bin/";

  # fzf
  [ "$arch" = "aarch64" ] && arch="arm64";
  ! command -v fzf > /dev/null; and curl -sL "https://github.com/junegunn/fzf/releases/download/0.46.0/fzf-0.46.0-linux_$arch.tar.gz" | tar xz -C "$PWD/bin/";

  # browserpass
  [ -d "/opt/homebrew/opt/browserpass" ];
    and PREFIX='/opt/homebrew/opt/browserpass' \
    make hosts-firefox-user -f '/opt/homebrew/opt/browserpass/lib/browserpass/Makefile';
}

function install_lsp_servers() {
  true; and "$MAYBE_SUDO" cpanm -n PLS::Server Neovim::Ext;
  true; and "$MAYBE_SUDO" npm -g install \
    emmet-ls                   neovim                        \
    bash-language-server       svelte-language-server        \
    typescript                 typescript-language-server    \
    @volar/vue-language-server vscode-langservers-extracted  \
    yaml-language-server;
}

function setup_macos() {
  [ "$(uname -o)" = "Darwin" ] || return 0;
  true; and defaults write NSGlobalDomain InitialKeyRepeat -int 15;
  true; and defaults write NSGlobalDomain KeyRepeat -int 2;
  true; and defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE;
  true; and defaults write com.apple.screencapture location $HOME/Downloads;
  true; and defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false;
  true; and defaults write -g ApplePressAndHoldEnabled -bool false;
}

function install_all() {
  install_brew;
  install_cpanm;
  install_misc;
  install_dotfiles;
  install_lsp_servers;
  setup_macos;
}

function install_basic() {
  install_cpanm;
  install_dotfiles;
}

function command_usage() {
  echo "Usage:
  \$ bash ./install.sh -s macos;
  \$ bash ./install.sh -i all;
  \$ bash ./install.sh -i basic;
  \$ bash ./install.sh -i brew;
  \$ bash ./install.sh -i cpanm;
  \$ bash ./install.sh -i misc;
  \$ bash ./install.sh -i dotfiles;
  \$ bash ./install.sh -i lsp_servers;
";
}

function main() {
  local -a unparsed;
  local command="install_basic";

  while [ -n "$*" ]; do case "$1" in
    --help) shift; command="command_usage"; break ;;
    --no-update) shift; export SKIP_UPDATE="1" ;;
    -i) shift; command="install_$1"; shift ;;
    -s) shift; command="setup_$1"; shift ;;
    *) unparsed+=("$1"); shift ;;
  esac done

  "$command" "${unparsed[@]}";
}

main "$@";
