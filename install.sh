#!/bin/zsh

XDG_CONFIG_DIR="$HOME/.config";
XDG_DATA_HOME="$HOME/.local/share";

install_misc() {
  lnk "config/ackrc" "$HOME/.ackrc";
  lnk "config/dataprinter" "$HOME/.dataprinter";
  lnk "config/git" "$XDG_CONFIG_DIR/git";
  lnk "config/lf" "$XDG_CONFIG_DIR/lf";
  lnk "config/perltidyrc" "$HOME/.perltidyrc";
}

install_tmux() {
  lnk "config/tmux/tmux.conf" "$HOME/.tmux.conf";
  [ ! -d ~/.tmux/plugins ]; and mkdir -p ~/.tmux/plugins;
  [ ! -d ~/.tmux/plugins/tpm ]; and git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_nvim() {
  lnk "config/nvim" "$XDG_CONFIG_DIR/nvim";
  [ ! -d "$XDG_DATA_HOME/nvim/site/pack" ]; and mkdir -p "$XDG_DATA_HOME/nvim/site/pack"
  lnk "share/nvim/site/pack/batpack" "$XDG_DATA_HOME/nvim/site/pack/batpack";
  ./config/nvim/submodule.sh update;
}

install_wezterm() {
  lnk "config/wezterm" "$HOME/.config/wezterm";
  true; and wezterm shell-completion --shell zsh > ~/.config/zsh/completion/wezterm.zsh-completion;
  true; and curl -sL https://raw.githubusercontent.com/wez/wezterm/main/assets/shell-integration/wezterm.sh > "$XDG_CONFIG_DIR/zsh/30-wezterm.sh";
}

install_zsh() {
  local arch="$(uname -p)";
  local os="$(uname -s | grep -qi linux && echo 'unknown-linux' || echo 'apple')";
  local flavor="$(uname -o | grep -qi gnu && echo gnu || echo darwin)";
  lnk "config/zsh" "$XDG_CONFIG_DIR/zsh";
  lnk "config/starship.toml" "$XDG_CONFIG_DIR/starship.toml";
  lnk "config/zsh/zshrc" "$HOME/.zshrc";
  [ ! -d ~/.config/zsh/zsh-vi-mode ]; and git clone https://github.com/jeffreytse/zsh-vi-mode ~/.config/zsh/zsh-vi-mode;
  [ -d "$HOMEBREW_PREFIX" ] \
    && lnk "$HOMEBREW_PREFIX/etc/profile.d/z.sh" "$XDG_CONFIG_DIR/zsh/15-z.sh";
  [ -d "$HOMEBREW_PREFIX" ] \
    && lnk "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$XDG_CONFIG_DIR/zsh/25-zsh-syntax-highlighting.zsh";
  run curl -sL https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh > ./config/zsh/02-fzf-key-bindings.zsh;
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

lnk() {
  local from="$(readlink_f "$1")";
  local to="$2";
  [ -L "$to" ] && [ ! -r "$to" ] && run rm "$to"; # Remove broken links
  [ ! -L "$to" ]; and ln -s "$from" "$to";
}

readlink_f() {
  [ "x$UNAME" = "xDarwin" ] && readlink "$@" || readlink -f "$@";
}

true; and install_zsh;
true; and install_misc;
true; and install_tmux;
true; and install_nvim;
command -v wezterm > /dev/null; and install_wezterm;
[ "$(uname -o)" = "Darwin" ]; and ./bin/macos-setup.sh;
[ "$(uname -o)" = "Darwin" ]; and ./bin/lsp-servers;
command -v starship > /dev/null || run curl -sL "https://github.com/starship/starship/releases/latest/download/starship-$arch-$os-$flavor.tar.gz" | tar xz -C "$PWD/bin/";
command -v fzf > /dev/null || run curl -sL "https://github.com/junegunn/fzf/releases/download/0.43.0/fzf-0.43.0-linux_amd64.tar.gz" | tar xz -C "$PWD/bin/";
