#!/bin/zsh
[ "x$1" = "x-x" ] || DRY_RUN=1;

function abort() {
  echo "# ERROR $*";
  exit 1;
}

function lnk() {
  FROM="$(readlink -f $1)";
  TO="$2";
  [ -e $FROM ] || abort "$1 cannot be found.";
  [ -L $TO -a ! -r $TO ] && run rm $TO; # Remove broken links
  [ -e $TO ] && echo "# $TO exists" || run ln -s $FROM $TO;
  [ "x$IMPORT" = "x1" -a ! -L $TO ] && run cp $TO $FROM;
}

function run() {
  echo "> $*";
  [ "x$DRY_RUN" = "x" ] && $*;
}

function setup_alacritty() {
  [ -d "$HOME/.config/alacritty" ] || run mkdir -p $HOME/.config/alacritty;
  lnk $SOURCE/alacritty.yml $HOME/.config/alacritty/alacritty.yml;
}

function setup_misc() {
  lnk dotfiles/ackrc $HOME/.ackrc;
  lnk dotfiles/git/gitconfig $HOME/.gitconfig;
  lnk dotfiles/git/gitignore_global $HOME/.gitignore_global;
  lnk dotfiles/perltidyrc $HOME/.perltidyrc;
  lnk dotfiles/tmux.conf $HOME/.tmux.conf;
  [ -f $HOME/.pause ] || run cp dotfiles/pause $HOME/.pause;
}

function setup_vim() {
  lnk dotfiles/vim $HOME/.vim;
  [ -e "$HOME/.vim/autoload/plug.vim" ] || run curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  [ -d "$XDG_CONFIG_DIR/nvim" ] || run mkdir $XDG_CONFIG_DIR/nvim;
  lnk dotfiles/vim/nvim.vim $XDG_CONFIG_DIR/nvim/init.vim;
}

function setup_zsh() {
  lnk dotfiles/shell/path.sh $XDG_CONFIG_DIR/zsh/00-path.sh;
  lnk dotfiles/shell/env.sh  $XDG_CONFIG_DIR/zsh/01-env.sh;

  lnk dotfiles/shell/aliases.sh $XDG_CONFIG_DIR/zsh/10-aliases.sh;
  lnk dotfiles/shell/bindkey.sh $XDG_CONFIG_DIR/zsh/10-bindkey.sh;
  lnk dotfiles/shell/history.sh $XDG_CONFIG_DIR/zsh/10-history.sh;

  lnk /usr/local/etc/profile.d/z.sh $XDG_CONFIG_DIR/zsh/15-z.sh
  lnk dotfiles/shell/completion.sh $XDG_CONFIG_DIR/zsh/15-completion.sh;

  lnk dotfiles/shell/setkeylabel.sh $XDG_CONFIG_DIR/zsh/30-setkeylabel.sh;
  lnk dotfiles/shell/proxy.sh $XDG_CONFIG_DIR/zsh/50-proxy.sh
  lnk dotfiles/shell/zshrc $HOME/.zshrc;
}

function setup_zsh_scheme() {
  if ! autoload -Uz is-at-least || ! is-at-least 5.1; then
    lnk dotfiles/prompt/prompt-bmin.sh $XDG_CONFIG_DIR/zsh/02-prompt-bmin.sh;
  else
    if [ ! -d "$XDG_CONFIG_DIR/zsh/powerlevel10k" ]; then
      run git clone https://github.com/romkatv/powerlevel10k.git $XDG_CONFIG_DIR/zsh/powerlevel10k;
    fi

    lnk $XDG_CONFIG_DIR/zsh/powerlevel10k/powerlevel10k.zsh-theme $XDG_CONFIG_DIR/zsh/20-theme-powerlevel10k.sh;
    lnk dotfiles/prompt/p10k.zsh $XDG_CONFIG_DIR/zsh/21-p10k.zsh;
  fi

  lnk /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh $XDG_CONFIG_DIR/zsh/25-zsh-syntax-highlighting.zsh
  lnk dotfiles/shell/gruvbox.sh $XDG_CONFIG_DIR/zsh/25-gruvbox.sh;
}

# NOTE XDG_CONFIG_DIR != XDG_CONFIG_DIRS
XDG_CONFIG_DIR="$HOME/.config";
SOURCE="$(readlink -f dotfiles)";
[ -z $SOURCE -o ! -d $SOURCE ] && abort "Cannot find ./dotfiles ($SOURCE)";
[ -d $XDG_CONFIG_DIR/zsh ] || mkdir -p $XDG_CONFIG_DIR/zsh;

setup_alacritty;
setup_misc;
setup_zsh;
setup_zsh_scheme;
setup_vim;
