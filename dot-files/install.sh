#!/bin/zsh

if [ "x$1" = "xapps" ]; then
  # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update;
  brew install \
    ack \
    bindfs \
    chromedriver \
    cloc \
    coreutils \
    cowsay \
    cpanm \
    ctags \
    diff-so-fancy \
    docker \
    docker-compose \
    docker-machine \
    doctl \
    exiftool \
    fd \
    ffmpeg \
    figlet \
    fontconfig \
    freetype \
    fswatch \
    geckodriver \
    geoip \
    git \
    git-secret \
    glances \
    gnupg \
    gnutls \
    go \
    gopass \
    homebrew/completions/tmuxinator-completion \
    imagemagick \
    ircd-hybrid \
    jpeg \
    jpegoptim \
    kubernetes-cli \
    less \
    mkcert \
    mysql \
    mysql-client \
    nginx \
    nmap \
    node \
    openssl \
    perl \
    pinentry \
    pngcrush \
    postgresql \
    psgrep \
    pstree \
    python \
    redis \
    rename \
    ruby \
    rust \
    sqlite \
    ssh-copy-id \
    sshfs \
    sshuttle \
    telnet \
    terraform \
    terraform-docs \
    tesseract \
    tmux \
    tmuxinator-completion \
    tree \
    vim \
    wget \
    z \
    zsh \
    zsh-completions \
    zsh-git-prompt \
    zsh-lovers \
    zsh-syntax-highlighting \
  ;

  cpanm -n App::errno
  cpanm -n App::git::ship
  cpanm -n App::githook_perltidy
  cpanm -n App::githook::perltidy
  cpanm -n App::pause
  cpanm -n App::podify
  cpanm -n App::prowess
  cpanm -n App::tt
  cpanm -n Devel::Cover

  rm /usr/local/bin/githook-perltidy;
  ln -s "$(which githook-perltidy)" /usr/local/bin/githook-perltidy

elif [ "x$1" = "xdotfiles" ]; then
  CONFIG_DIR="$HOME/.config/dot-files";
  ROOT_DIR="${0:a:h}";
  [ "x$ROOT_DIR" = "x" ] && exit 1;

  function install_file() {
    SOURCE_FILE="$1";
    DEST_FILE="$2";
    LINK_FILE=$(readlink $DEST_FILE);

    if [ ! -e $SOURCE_FILE ]; then
      echo "--- Skip $SOURCE_FILE - Not found";
      return;
    fi

    # Clean up broken links
    [ -L "$DEST_FILE" -a ! -e "$DEST_FILE" ] && rm $DEST_FILE;

    if [ ! -e "$DEST_FILE" ]; then
      echo "--- Installing $DEST_FILE";
      ln -s "$SOURCE_FILE" "$DEST_FILE";
    elif [ "x$LINK_FILE" != "x$SOURCE_FILE" ]; then
      echo "--- Skip $SOURCE_FILE - $LINK_FILE exists";
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
  install_file $ROOT_DIR/.ackrc $HOME/.ackrc
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
  install_file $ROOT_DIR/bindkey.sh $CONFIG_DIR/10-bindkey.sh
  install_file $ROOT_DIR/history.sh $CONFIG_DIR/10-history.sh
  install_file $ROOT_DIR/completion.sh $CONFIG_DIR/15-completion.sh
  install_file $ROOT_DIR/setkeylabel.sh $CONFIG_DIR/30-setkeylabel.sh

  # Brew and iTerm
  install_file /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc $CONFIG_DIR/15-google-cloud-sdk-path.sh
  install_file /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc $CONFIG_DIR/15-google-cloud-sdk-completion.sh
  install_file /usr/local/etc/profile.d/z.sh $CONFIG_DIR/15-z.sh
  install_file /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh $CONFIG_DIR/15-zsh-syntax-highlighting.zsh
  install_file $HOME/.iterm2_shell_integration.zsh $CONFIG_DIR/15-iterm2_shell_integration.sh

  # Utility scripts
  install_file $ROOT_DIR/../bin $CONFIG_DIR/bin

  # misc
  [ -e "$HOME/.vim/autoload/plug.vim" ] || curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  [ -e "$HOME/.pause" ] || cp $ROOT_DIR/.pause $HOME/.pause

elif [ "x$1" = "xsettings" ]; then
  defaults read NSGlobalDomain InitialKeyRepeat # 25
  defaults write NSGlobalDomain InitialKeyRepeat -int 12
  defaults read NSGlobalDomain KeyRepeat # 2
  defaults write NSGlobalDomain KeyRepeat -int 0
  defaults write com.apple.screencapture location /Users/jhthorsen/Downloads
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  # killall SystemUIServer

  curl -L https://iterm2.com/misc/install_shell_integration.sh | zsh

else
  echo "Usage: zsh $0 [apps|dotfiles|settings]";
fi
