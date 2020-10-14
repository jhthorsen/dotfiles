#!/bin/zsh

if [ "x$1" = "xapps" ]; then
  # ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update && brew install                                                            \
    ack                      bindfs          chromedriver                                \
    cloc                     coreutils       cowsay                                      \
    cpanm                    ctags           diff-so-fancy                               \
    docker                   docker-compose  docker-machine                              \
    doctl                    exiftool        fd                                          \
    ffmpeg                   figlet          fontconfig                                  \
    freetype                 fswatch         geckodriver                                 \
    geoip                    git             git-secret                                  \
    glances                  gnupg           gnutls                                      \
    go                       gopass          homebrew/completions/tmuxinator-completion  \
    imagemagick              ircd-hybrid     jpeg                                        \
    jpegoptim                kubernetes-cli  less                                        \
    mkcert                   mysql           mysql-client                                \
    nginx                    nmap            node                                        \
    openssl                  perl            pinentry                                    \
    pngcrush                 postgresql      psgrep                                      \
    pstree                   python          redis                                       \
    rename                   ruby            rust                                        \
    sqlite                   ssh-copy-id     sshfs                                       \
    sshuttle                 telnet          terraform                                   \
    terraform-docs           tesseract       tmux                                        \
    tmuxinator-completion    tree            vim                                         \
    wget                     z               zsh                                         \
    zsh-completions          zsh-git-prompt  zsh-lovers                                  \
    zsh-syntax-highlighting                                                              ;

  cpanm -n App::errno;
  cpanm -n App::git::ship;
  cpanm -n App::githook_perltidy;
  cpanm -n App::githook::perltidy;
  cpanm -n App::pause;
  cpanm -n App::podify;
  cpanm -n App::prowess;
  cpanm -n App::tt;
  cpanm -n Devel::Cover;

  rm /usr/local/bin/githook-perltidy;
  ln -s "$(which githook-perltidy)" /usr/local/bin/githook-perltidy;

elif [ "x$1" = "xdotfiles" -o "x$DOTFILES_FROM_WEB" = "x1" ]; then
  BASE_WEB_URL="https://raw.githubusercontent.com/jhthorsen/snippets/master/dot-files";
  CONFIG_DIR="$HOME/.config/dot-files";
  ROOT_DIR="${0:a:h}";
  ROOT_DIR="${ROOT_DIR:-HTTPS}";
  [ "x$ROOT_DIR" = "x" -a "x$DOTFILES_FROM_WEB" != "x1" ] && exit 1;
  [ -d "$HOME/.config/alacritty" ] || mkdir -p $HOME/.config/alacritty

  function install_file() {
    SOURCE_FILE="$1";
    DEST_FILE="$2";
    LINK_FILE=$(readlink $DEST_FILE);
    WEB_PATH="$SOURCE_FILE";

    # Clean up broken links
    [ -L "$DEST_FILE" -a ! -e "$DEST_FILE" ] && $DRY_RUN rm $DEST_FILE;

    [ "x$DOTFILES_FROM_WEB" = "x1" -a -e "$DEST_FILE" ] && $DRY_RUN rm $DEST_FILE;
    [ "x$DOTFILES_FROM_WEB" = "x1" ] && WEB_PATH=$(echo $SOURCE_FILE | sed "s#^$ROOT_DIR##");

    if [ ! -e $SOURCE_FILE -a "x$WEB_PATH" = "x$SOURCE_FILE" ]; then
      echo "--- Skip $SOURCE_FILE - Not found";
      return;
    fi

    if [ $WEB_PATH != $SOURCE_FILE ]; then
      echo "--- Installing $DEST_FILE";
      $DRY_RUN curl -sL $BASE_WEB_URL$WEB_PATH -o "$DEST_FILE";
    elif [ ! -e "$DEST_FILE" ]; then
      echo "--- Installing $DEST_FILE";
      $DRY_RUN ln -s "$SOURCE_FILE" "$DEST_FILE";
    elif [ "x$LINK_FILE" != "x$SOURCE_FILE" ]; then
      echo "--- Skip $SOURCE_FILE - $LINK_FILE exists";
    else
      echo "--- Installed $DEST_FILE";
    fi
  }

  # prompt
  if ! autoload -Uz is-at-least || ! is-at-least 5.1; then
    install_file $ROOT_DIR/prompt-bmin.sh $CONFIG_DIR/02-prompt-bmin.sh
  else
    if [ ! -d "$CONFIG_DIR/powerlevel10k" ]; then
      $DRY_RUN git clone https://github.com/romkatv/powerlevel10k.git $CONFIG_DIR/powerlevel10k
    fi

    install_file $CONFIG_DIR/powerlevel10k/powerlevel10k.zsh-theme $CONFIG_DIR/20-theme-powerlevel10k.sh
    install_file $ROOT_DIR/.p10k.zsh $CONFIG_DIR/21-p10k.zsh
  fi

  # dot-files
  install_file $ROOT_DIR/.ackrc $HOME/.ackrc
  install_file $ROOT_DIR/.gitconfig $HOME/.gitconfig
  install_file $ROOT_DIR/.gitignore_global $HOME/.gitignore_global
  install_file $ROOT_DIR/.perltidyrc $HOME/.perltidyrc
  install_file $ROOT_DIR/.tmux.conf $HOME/.tmux.conf
  install_file $ROOT_DIR/.vimrc $HOME/.vimrc
  install_file $ROOT_DIR/.zshrc $HOME/.zshrc
  install_file $ROOT_DIR/alacritty.yml $HOME/.config/alacritty/alacritty.yml

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

  # Vim includes
  if [ "x$DOTFILES_FROM_WEB" = "x1" ]; then
    [ -d "$HOME/.vim/ftplugin" ] || mkdir -p "$HOME/.vim/ftplugin";
    [ -d "$HOME/.vim/include" ] || mkdir -p "$HOME/.vim/include";
    install_file $ROOT_DIR/.vim/ftplugin/perl.vim $HOME/.vim/ftplugin/perl.vim
    install_file $ROOT_DIR/.vim/include/coc.vim $HOME/.vim/include/coc.vim
    install_file $ROOT_DIR/.vim/include/colors.vim $HOME/.vim/include/colors.vim
    install_file $ROOT_DIR/.vim/include/emmet.vim $HOME/.vim/include/emmet.vim
    install_file $ROOT_DIR/.vim/include/ft.vim $HOME/.vim/include/ft.vim
    install_file $ROOT_DIR/.vim/include/fzf.vim $HOME/.vim/include/fzf.vim
    install_file $ROOT_DIR/.vim/include/keymap.vim $HOME/.vim/include/keymap.vim
    install_file $ROOT_DIR/.vim/include/lastpos.vim $HOME/.vim/include/lastpos.vim
    install_file $ROOT_DIR/.vim/include/mkdir.vim $HOME/.vim/include/mkdir.vim
    install_file $ROOT_DIR/.vim/include/multiple-cursors.vim $HOME/.vim/include/multiple-cursors.vim
    install_file $ROOT_DIR/.vim/include/spelling.vim $HOME/.vim/include/spelling.vim
    install_file $ROOT_DIR/.vim/include/template.vim $HOME/.vim/include/template.vim
  fi

  # misc
  [ -e "$HOME/.vim/autoload/plug.vim" ] || $DRY_RUN curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  [ -e "$HOME/.pause" -a -e "$ROOT_DIR/.pause" ] || $DRY_RUN cp $ROOT_DIR/.pause $HOME/.pause
  install_file $ROOT_DIR/proxy.sh $CONFIG_DIR/50-proxy.sh

elif [ "x$1" = "xpush" -a -n "$2" ]; then
  DEST_HOST="$2";
  rsync -va $HOME/.config $DEST_HOST:~/;
  rsync -va \
    $HOME/.ackrc \
    $HOME/.git* \
    $HOME/.perltidyrc \
    $HOME/.zshrc \
    $HOME/.vim* \
    $DEST_HOST:~/;

elif [ "x$1" = "xsettings" ]; then
  defaults read NSGlobalDomain InitialKeyRepeat # 25
  defaults write NSGlobalDomain InitialKeyRepeat -int 12
  defaults read NSGlobalDomain KeyRepeat # 2
  defaults write NSGlobalDomain KeyRepeat -int 0
  defaults write com.apple.screencapture location /Users/jhthorsen/Downloads
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  # killall SystemUIServer

  curl -sL https://iterm2.com/misc/install_shell_integration.sh | zsh

else
  cat <<HERE
# Notes
  initdb /usr/local/var/postgres -E utf8
  brew services restart postgresql
  git config --global commit.gpgsign false

# Usage
  ./dot-files [apps|dotfiles|settings]
  ./dot-files push <dest-host>
  DRY_RUN=echo ./dot-files/install.sh dotfiles
  curl -sL https://raw.githubusercontent.com/jhthorsen/snippets/master/dot-files/install.sh | DOTFILES_FROM_WEB=1 sh -
HERE
fi
