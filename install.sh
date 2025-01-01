#!/bin/bash
XDG_CONFIG_DIR="$HOME/.config";
XDG_DATA_HOME="$HOME/.local/share";
DOTFILES="$(cd -- "$(dirname "$0")" >/dev/null ; pwd -P)";
[ -n "$HOMEBREW_PREFIX" ] && MAYBE_SUDO="" || MAYBE_SUDO="sudo";

abort() {
  echo "! $*" >&2
  exit 1;
}

and() {
  local x="$?";
  [ "$x" = "0" ] && echo "> $*" >&2 || echo "# $*" >&2;
  [ "$x" = "0" ] && "$@";
}

run() {
  echo "> $*" >&2;
  "$@";
}

skip() {
  echo "# $*" >&2;
  echo 0; # return value
}

download_binary() {
  curl -sL "$1" | tar xz -C "$PWD/bin/";
}

lnk() {
  local from="$1";
  local to="$2";
  local parent; parent="$(dirname "$to")";
  [ -d "$parent" ] || mkdir -p "$parent" || exit;
  [ -L "$to" ] && [ ! -r "$to" ]; and rm "$to"; # Remove broken links
  [ ! -L "$to" ]; and ln -s "$from" "$to";
}

install_all() {
  install_cpanm;
  install_apps;
  install_lsp_servers;
  install_dotfiles;
  install_macos;
}

install_apps() {
  [ -z "$HOMEBREW_PREFIX" ] && return 1;
  local brew="$HOMEBREW_PREFIX/bin/brew";
  [ ! -x "$brew" ] && abort "ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\"";

  local arch; arch="$(arch)";
  local platform="unknown-linux-musl";

  # starship
  [ "$(uname -o)" = "Darwin" ] && platform="apple-darwin";
  [ "$(uname -o)" = "Darwin" ] && arch="aarch64";
  ! command -v starship > /dev/null; and download_binary "https://github.com/starship/starship/releases/latest/download/starship-$arch-$platform.tar.gz";

  # eza
  local arch; arch="$(arch)";
  ! command -v eza > /dev/null; and download_binary "https://github.com/eza-community/eza/releases/download/v0.17.3/eza_$arch-unknown-linux-gnu.tar.gz";

  # fzf
  [ "$arch" = "aarch64" ] && arch="arm64";
  ! command -v fzf > /dev/null; and download_binary "https://github.com/junegunn/fzf/releases/download/0.46.0/fzf-0.46.0-linux_$arch.tar.gz";

  # yubiswitch
  [ ! -e "/Applications/yubiswitch.app" ];
    and wget -Lq --output "$HOME/Downloads/yubiswitch.dmg" "https://github.com/pallotron/yubiswitch/releases/download/v0.16/yubiswitch_0.16.dmg";

  [ ! -e "/Applications/Easy Move+Resize.app" ];
    and brew install --cask easy-move-plus-resize;

  ! command -v im-select > /dev/null; and "$brew" tap daipeihust/tap;
  [ -z "$SKIP_UPDATE" ]; and "$brew" update; and "$brew" upgrade;

  install_brew_package "alt-tab" "/Applications/AltTab.app";
  install_brew_package "atuin";
  install_brew_package "balenaetcher" "/Applications/balenaEtcher.app";
  install_brew_package "bash-completion@2"
  install_brew_package "bat";
  install_brew_package "blender";
  install_brew_package "btop";
  install_brew_package "cloc";
  install_brew_package "coreutils";
  install_brew_package "cpanm";
  install_brew_package "csvprintf";
  install_brew_package "ctags";
  install_brew_package "exiftool";
  install_brew_package "eza";
  install_brew_package "fd";
  install_brew_package "ffmpeg";
  install_brew_package "figlet";
  install_brew_package "fontconfig";
  install_brew_package "freetype";
  install_brew_package "fsevents-tools";
  install_brew_package "fzf";
  install_brew_package "git";
  install_brew_package "gnupg";
  install_brew_package "gnutls";
  install_brew_package "go";
  install_brew_package "groff";
  install_brew_package "hopenpgp-tools";
  install_brew_package "imagemagick";
  install_brew_package "im-select";
  install_brew_package "jpeg";
  install_brew_package "jpegoptim";
  install_brew_package "less";
  install_brew_package "macdown";
  install_brew_package "mkcert";
  install_brew_package "mysql";
  install_brew_package "mysql-client";
  install_brew_package "neovim";
  install_brew_package "nextcloud" "/Applications/Nextcloud.app";
  install_brew_package "nginx";
  install_brew_package "nmap";
  install_brew_package "node";
  install_brew_package "openssh";
  install_brew_package "openssl";
  install_brew_package "pass";
  install_brew_package "perl";
  install_brew_package "pinentry-mac";
  install_brew_package "pngcrush";
  install_brew_package "postgresql@14";
  install_brew_package "procs";
  install_brew_package "psgrep";
  install_brew_package "python";
  install_brew_package "qrencode";
  install_brew_package "redis";
  install_brew_package "rename";
  install_brew_package "rg";
  install_brew_package "rmlint";
  install_brew_package "rsync";
  install_brew_package "ruby";
  install_brew_package "rust";
  install_brew_package "smartmontools";
  install_brew_package "sqlite";
  install_brew_package "ssh-copy-id";
  install_brew_package "sshuttle";
  install_brew_package "telnet";
  install_brew_package "termshark";
  install_brew_package "trash-cli";
  install_brew_package "ukelele" "/Applications/Ukelele.app";
  install_brew_package "wezterm";
  install_brew_package "wget";
  install_brew_package "ykman";
  install_brew_package "yubico-authenticator" "/Applications/Yubico Authenticator.app";
  install_brew_package "yubico-piv-tool";
  install_brew_package "yubico-yubikey-manager" "/Applications/YubiKey Manager.app";
  install_brew_package "yubikey-personalization" "/opt/homebrew/Cellar/ykpers";
  install_brew_package "z";
}

install_brew_package() {
  local name="$1";
  local file="${2:-"$1"}";
  [ -d "/opt/homebrew/Cellar" ] || return 0;
  [ -e "/opt/homebrew/Cellar/$name" ] && return "$(skip brew install "$name")";
  [ -e "$file" ] && return "$(skip brew install "$name")";
  command -v "$name" >/dev/null && return "$(skip brew install "$name")";
  brew install "$name";
}

install_cpanm() {
  true; and $MAYBE_SUDO cpanm -n \
    App::errno     App::githook_perltidy App::httpstatus  \
    App::pause     App::podify           App::tt          \
    CPAN::Uploader Devel::Cover          Getopt::App      \
    Mojolicious    Pod::Markdown         Term::ReadKey;   \
}

install_dotfiles() {
  # bash
  run "$DOTFILES/config/bash/bash_profile.sh" > "$HOME/.bash_profile";
  run "$DOTFILES/config/bash/bashrc.sh" > "$HOME/.bashrc";
  lnk "$DOTFILES/config/bash/inputrc" "$HOME/.inputrc";
  lnk "$DOTFILES/config/ghostty" "$XDG_CONFIG_DIR/ghostty";
  lnk "$DOTFILES/config/starship.toml" "$XDG_CONFIG_DIR/starship.toml";
  lnk "$DOTFILES/config/wezterm" "$XDG_CONFIG_DIR/wezterm";

  # nvim
  lnk "$DOTFILES/config/nvim" "$XDG_CONFIG_DIR/nvim";
  lnk "$DOTFILES/share/nvim/site/pack/batpack" "$XDG_DATA_HOME/nvim/site/pack/batpack";

  # misc
  lnk "$DOTFILES/config/ackrc" "$HOME/.ackrc";
  lnk "$DOTFILES/config/dataprinter" "$HOME/.dataprinter";
  lnk "$DOTFILES/config/git" "$XDG_CONFIG_DIR/git";
  lnk "$DOTFILES/config/git/gitignore" "$HOME/.gitignore";
  lnk "$DOTFILES/config/lf" "$XDG_CONFIG_DIR/lf";
  lnk "$DOTFILES/config/perlcriticrc" "$HOME/.perlcriticrc";
  lnk "$DOTFILES/config/perltidyrc" "$HOME/.perltidyrc";
  lnk "$HOME/Nextcloud/.password-store" "$HOME/.password-store";
}

install_gnupg() {
  export GNUPGHOME="$HOME/.gnupg";
  export BACKUP_GNUPGHOME="${BACKUP_GNUPGHOME:-/BACKUP_GNUPGHOME}";

  local email; email="$(git config --get user.email)";
  [ -z "$email" ] && abort "git config user.email is not set";

  [ ! -d "$GNUPGHOME" ]; and mkdir "$GNUPGHOME";
  true; and chmod 700 "$GNUPGHOME";

  [ ! -e "$GNUPGHOME/gpg.conf" ];
    and curl -Lq --output "$GNUPGHOME/gpg.conf" "https://raw.githubusercontent.com/drduh/config/master/gpg.conf";

  [ ! -e "$GNUPGHOME/gpg-agent.conf" ];
    and curl -Lq --output "$GNUPGHOME/gpg-agent.conf" "https://raw.githubusercontent.com/drduh/config/master/gpg-agent.conf";

  cat << HERE

# Might want to adjust these config values:
# $GNUPGHOME/gpg-agent.conf
# - pinentry-program
# - max-cache-ttl

HERE

  [ -e "$BACKUP_GNUPGHOME/private-keys-v1.d" ] && [ ! -e "$GNUPGHOME/private-keys-v1.d" ];
    and rsync -va "$BACKUP_GNUPGHOME/private-keys-v1.d/" "$GNUPGHOME/private-keys-v1.d/";

  [ -e "$BACKUP_GNUPGHOME/pubring.kbx" ] && [ ! -e "$GNUPGHOME/pubring.kbx" ];
    and rsync -va "$BACKUP_GNUPGHOME/pubring.kbx" "$GNUPGHOME/pubring.kbx";

  [ -e "$BACKUP_GNUPGHOME/revoke.asc" ] && [ ! -e "$GNUPGHOME/revoke.asc" ];
    and rsync -va "$BACKUP_GNUPGHOME/revoke.asc" "$GNUPGHOME/revoke.asc";

  [ -e "$BACKUP_GNUPGHOME/trustdb.gpg" ] && [ ! -e "$GNUPGHOME/trustdb.gpg" ];
    and rsync -va "$BACKUP_GNUPGHOME/trustdb.gpg" "$GNUPGHOME/trustdb.gpg";

  if [ -n "$GPG_TEST" ]; then
    true; and echo "test encrypting and decrypting with gpg" \
      | gpg --encrypt --armor --recipient "$email" \
      | gpg --decrypt --armor - && echo "# gpg works!";
  fi

  if [ -n "$GPG_EXPIRE_TIME" ]; then
    local n_keys; n_keys="$(gpg --list-keys "$email" | grep "^sub " | wc -l | sed -E 's/[^0-9]+//g')";
    for idx in $(seq 1 "$n_keys"); do
      echo "${GPG_EXPIRE_TIME:-6m}" | run gpg --command-fd 0 --edit-key "$email" "key $idx" "expire" "save";
    done
  fi
}

install_lsp_servers() {
  # sudo xcodebuild -license accept
  install_brew_package lua-language-server;
  install_brew_package yaml-language-server;

  true; and $MAYBE_SUDO cpanm -n PLS::Server Neovim::Ext;
  true; and $MAYBE_SUDO npm -g install \
    emmet-ls                   neovim                        \
    bash-language-server       svelte-language-server        \
    typescript                 typescript-language-server    \
    @volar/vue-language-server vscode-langservers-extracted  \
    yaml-language-server;
}

install_macos() {
  [ "$(uname -o)" = "Darwin" ] || return 0;
  defaults_write -globalDomain InitialKeyRepeat 15;
  defaults_write -globalDomain KeyRepeat 2;
  defaults_write -globalDomain NSAutomaticCapitalizationEnabled false;
  defaults_write -globalDomain NSAutomaticPeriodSubstitutionEnabled false;
  defaults_write -globalDomain NSAutomaticSpellingCorrectionEnabled false;
  defaults_write -globalDomain com.apple.trackpad.scaling 2;
  defaults_write NSGlobalDomain AppleShowAllExtensions true;
  defaults_write com.apple.Accessibility KeyRepeatDelay 0.25;
  defaults_write com.apple.Accessibility KeyRepeatInterval-string  0.03;
  defaults_write com.apple.desktopservices DSDontWriteNetworkStores true;
  defaults_write com.apple.dock autohide-delay 1;
  defaults_write com.apple.dock autohide-time-modifier 0.4
  defaults_write com.apple.dock largesize 70;
  defaults_write com.apple.dock magnification 1;
  defaults_write com.apple.dock tilesize 41;
  defaults_write com.apple.finder FXPreferredGroupBy Kind;
  defaults_write com.apple.finder FXPreferredViewStyle Nlsv;
  defaults_write com.apple.finder FXRemoveOldTrashItems 1;
  defaults_write com.apple.finder NewWindowTargetPath "file://$HOME/";
  defaults_write com.apple.finder ShowExternalHardDrivesOnDesktop 0;
  defaults_write com.apple.finder ShowHardDrivesOnDesktop 0;
  defaults_write com.apple.finder ShowPathbar true;
  defaults_write com.apple.finder ShowRecentTags 0;
  defaults_write com.apple.finder ShowRemovableMediaOnDesktop 0;
  defaults_write com.apple.menuextra.clock ShowDayOfWeek false;
  defaults_write com.apple.screencapture location "$HOME/Downloads";
  defaults_write com.microsoft.VSCode ApplePressAndHoldEnabled false;

  for app in "Dock" "Finder"; do
    [ "$RESTART_AFFECTED_APPS" = "yes" ]; and killall "${app}";
  done
}

defaults_write() {
  local type; type="$(defaults read-type "$@" | sed 's/.* is //')";
  true; and defaults write  "$1" "$2" -"$type" "$3";
}

command_usage() {
  echo "Usage:
  \$ bash ./install.sh macos;
  \$ bash ./install.sh dotfiles;
  \$ bash ./install.sh gnupg;
  \$ bash ./install.sh all;
  \$ bash ./install.sh apps;
  \$ bash ./install.sh cpanm;
  \$ bash ./install.sh lsp_servers;
";
}

main() {
  local -a unparsed;
  local command="command_usage";

  while [ -n "$*" ]; do case "$1" in
    --help) shift; command="command_usage"; break ;;
    --no-update) shift; export SKIP_UPDATE="1" ;;
    *) command="install_$1"; shift ;;
  esac done

  "$command" "${unparsed[@]}";
}

main "$@";
