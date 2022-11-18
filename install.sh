#!/bin/zsh

abort() {
  echo "# ERROR $*" >&2;
  exit 1;
}

lnk() {
  FROM="$(readlink_f $1)";
  TO="$2";
  [ ! -e $1 ] && abort "$1 cannot be found";
  [ "x$IMPORT" = "x1" -a ! -L $TO ] && run cp $TO $FROM;
  [ -L $TO -a ! -r $TO ] && run rm $TO; # Remove broken links
  [ -L $TO ] || run ln -s $FROM $TO;
}

readlink_f() {
  [ "x$UNAME" = "xDarwin" ] && readlink $* || readlink -f $*;
}

run() {
  echo "> $*" >&2;
  [ "x$DRY_RUN" = "x" ] && $*;
}

install_misc() {
  lnk config/ackrc $HOME/.ackrc;
  lnk config/git $XDG_CONFIG_DIR/git;
  lnk config/lf $XDG_CONFIG_DIR/lf;
}

install_tmux() {
  lnk config/tmux/tmux.conf $HOME/.tmux.conf;
  [ -d ~/.tmux/plugins ] || mkdir -p ~/.tmux/plugins;
  [ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_nvim() {
  lnk config/nvim $XDG_CONFIG_DIR/nvim;
  [ -d "$XDG_DATA_HOME/nvim/site/pack" ] || mkdir -p "$XDG_DATA_HOME/nvim/site/pack"
  lnk "share/nvim/site/pack/batpack" "$XDG_DATA_HOME/nvim/site/pack/batpack";
}

install_wezterm() {
  lnk config/wezterm $HOME/.config/wezterm;
  [ -e "$HOME/.config/wezterm/private_launch_menu.lua" ] || echo 'return {}' > "$HOME/.config/wezterm/private_launch_menu.lua";
  [ -e "$HOME/.config/wezterm/private_ssh_domains.lua" ] || echo 'return {}' > "$HOME/.config/wezterm/private_ssh_domains.lua";
  wezterm shell-completion --shell zsh > ~/.config/zsh/completion/wezterm.zsh-completion;
  wget -qO $XDG_CONFIG_DIR/zsh/30-wezterm.sh https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh;
}

install_zsh() {
  lnk config/zsh $XDG_CONFIG_DIR/zsh;
  lnk config/starship.toml $XDG_CONFIG_DIR/starship.toml;
  lnk config/zsh/zshenv $HOME/.zshenv;
  lnk config/zsh/zshrc $HOME/.zshrc;
  [ -d "$HOMEBREW_PREFIX" ] \
    && lnk $HOMEBREW_PREFIX/etc/profile.d/z.sh $XDG_CONFIG_DIR/zsh/15-z.sh;
  [ -d "$HOMEBREW_PREFIX" ] \
    && lnk $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh $XDG_CONFIG_DIR/zsh/25-zsh-syntax-highlighting.zsh
}

XDG_CONFIG_DIR="$HOME/.config";
XDG_DATA_HOME="$HOME/.local/share";

install_zsh;
install_wezterm;
install_misc;
install_tmux;
install_nvim;
