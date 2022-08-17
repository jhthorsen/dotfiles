#!/bin/zsh
function abort() {
  echo "# ERROR $*" >&2;
  exit 1;
}

function lnk() {
  FROM="$(readlink -f $1)";
  TO="$2";
  [ ! -e $1 ] && abort "$1 cannot be found";
  [ "x$IMPORT" = "x1" -a ! -L $TO ] && run cp $TO $FROM;
  [ -L $TO -a ! -r $TO ] && run rm $TO; # Remove broken links
  [ -L $TO ] || run ln -s $FROM $TO;
}

function run() {
  echo "> $*" >&2;
  [ "x$DRY_RUN" = "x" ] && $*;
}

function install_misc() {
  lnk config/ackrc $HOME/.ackrc;
  lnk config/git/gitignore_global $HOME/.gitignore_global;
  run perl config/git/generate.pl;
}

function install_tmux() {
  lnk config/tmux/tmux.conf $HOME/.tmux.conf;
  [ -d ~/.tmux/plugins ] || mkdir -p ~/.tmux/plugins;
  [ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

function install_vi() {
  lnk config/vim $XDG_CONFIG_DIR/vim;
  [ -e "$XDG_CONFIG_DIR/vim/autoload/plug.vim" ] || run curl -sfLo "$XDG_CONFIG_DIR/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  lnk config/nvim $XDG_CONFIG_DIR/nvim;
  [ -d "$XDG_DATA_HOME/nvim/site/pack/packer/start" ] \
    || git clone --depth 1 https://github.com/wbthomason/packer.nvim $XDG_DATA_HOME/nvim/site/pack/packer/start/packer.nvim;
}

function install_wezterm() {
  lnk config/wezterm $HOME/.config/wezterm;
  [ -e "$HOME/.config/wezterm/private_launch_menu.lua" ] || echo 'return {}' > "$HOME/.config/wezterm/private_launch_menu.lua";
  [ -e "$HOME/.config/wezterm/private_ssh_domains.lua" ] || echo 'return {}' > "$HOME/.config/wezterm/private_ssh_domains.lua";
  wezterm shell-completion --shell zsh > ~/.config/zsh/completion/wezterm.zsh-completion;
  wget -qO $XDG_CONFIG_DIR/zsh/30-wezterm.sh https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh;
}

function install_zsh() {
  lnk config/zsh $XDG_CONFIG_DIR/zsh;
  lnk config/zsh/zshrc $HOME/.zshrc;

  [ -d "$HOMEBREW_PREFIX" ] \
    && lnk $HOMEBREW_PREFIX/etc/profile.d/z.sh $XDG_CONFIG_DIR/zsh/15-z.sh;

  if autoload -Uz is-at-least && is-at-least 5.1; then
    [ -d "$XDG_CONFIG_DIR/zsh/powerlevel10k" ] \
      || run git clone https://github.com/romkatv/powerlevel10k.git $XDG_CONFIG_DIR/zsh/powerlevel10k;
    lnk $XDG_CONFIG_DIR/zsh/powerlevel10k/powerlevel10k.zsh-theme $XDG_CONFIG_DIR/zsh/20-theme-powerlevel10k.sh;
  fi

  [ -d "$HOMEBREW_PREFIX" ] \
    && lnk $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh $XDG_CONFIG_DIR/zsh/25-zsh-syntax-highlighting.zsh
}

XDG_CONFIG_DIR="$HOME/.config";
XDG_DATA_HOME="$HOME/.local/share";

install_zsh;
install_wezterm;
install_misc;
install_tmux;
install_vi;
