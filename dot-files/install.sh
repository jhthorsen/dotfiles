#!/bin/zsh

CONFIG_DIR="$HOME/.config/dot-files";
ROOT_DIR="${0:a:h}";
[ "x$ROOT_DIR" = "x" ] && exit 1;

function install_file() {
  SOURCE_FILE="$1";
  DEST_FILE="$2";
  LINK_FILE=$(readlink $DEST_FILE);

  # Clean up broken links
  [ -L "$DEST_FILE" -a ! -e "$DEST_FILE" ] && rm $DEST_FILE;

  if [ ! -e "$DEST_FILE" ]; then
    echo "--- Installing $DEST_FILE";
    ln -s "$SOURCE_FILE" "$DEST_FILE";
  elif [ "x$LINK_FILE" != "x$SOURCE_FILE" ]; then
    echo "--- Skip $SOURCE_FILE ($LINK_FILE)";
  else
    echo "--- Installed $DEST_FILE";
  fi
}

# powerlevel10k
if [ ! -d "$CONFIG_DIR/powerlevel10k" ]; then
  git clone https://github.com/romkatv/powerlevel10k.git $CONFIG_DIR/powerlevel10k
fi

install_file $CONFIG_DIR/powerlevel10k/powerlevel10k.zsh-theme $CONFIG_DIR/20-theme-powerlevel10k.sh
install_file $ROOT_DIR/.p10k.zsh $CONFIG_DIR/21-p10k.zsh

# dot-files
install_file $ROOT_DIR/.gitconfig $HOME/.gitconfig
install_file $ROOT_DIR/.gitignore_global $HOME/.gitignore_global
install_file $ROOT_DIR/.perltidyrc $HOME/.perltidyrc
install_file $ROOT_DIR/.tmux.conf $HOME/.tmux.conf
install_file $ROOT_DIR/.vimrc $HOME/.vimrc
install_file $ROOT_DIR/.zshrc $HOME/.zshrc

# .zshrc dependencies
install_file $ROOT_DIR/path.sh $CONFIG_DIR/00-path.sh
install_file $ROOT_DIR/env.sh $CONFIG_DIR/01-env.sh
install_file $ROOT_DIR/aliases.sh $CONFIG_DIR/10-aliases.sh
install_file $ROOT_DIR/history.sh $CONFIG_DIR/10-history.sh
install_file $ROOT_DIR/setkeylabel.sh $CONFIG_DIR/30-setkeylabel.sh
