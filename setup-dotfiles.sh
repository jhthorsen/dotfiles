#!/bin/zsh
# Check out:
# - neoman

function abort() {
  echo "# ERROR $*" >&2;
  exit 1;
}

function lnk() {
  FROM="$(readlink -f $1)";
  TO="$2";
  [ ! -e $1 ] && echo "# ERROR $1 cannot be found" && return 1;
  [ "x$IMPORT" = "x1" -a ! -L $TO ] && run cp $TO $FROM;
  [ -L $TO -a ! -r $TO ] && run rm $TO; # Remove broken links
  [ -L $TO ] || run ln -s $FROM $TO;
}

function run() {
  echo "> $*" >&2;
  [ "x$DRY_RUN" = "x" ] && $*;
}

function setup_misc() {
  lnk dotfiles/ackrc $HOME/.ackrc;
  lnk dotfiles/git/gitconfig $HOME/.gitconfig;
  lnk dotfiles/git/gitignore_global $HOME/.gitignore_global;
  [ -d $XDG_CONFIG_DIR/zsh/completion ] || run mkdir -p $XDG_CONFIG_DIR/zsh/completion;
  [ -e $XDG_CONFIG_DIR/zsh/completion/gopass.zsh ] \
    || run curl https://raw.githubusercontent.com/gopasspw/gopass/master/zsh.completion > $XDG_CONFIG_DIR/zsh/completion/_gopass;
}

function setup_perl() {
  [ -f $HOME/.pause ] || run cp dotfiles/pause $HOME/.pause;
  lnk dotfiles/perltidyrc $HOME/.perltidyrc;
  local PERL_LL_ROOT="$XDG_DATA_HOME/perl5";
  which brew &>/dev/null || run cpanm --local-lib=$PERL_LL_ROOT -n local::lib;
  [ -d $PERL_LL_ROOT ] && run perl -I$PERL_LL_ROOT/lib/perl5 -Mlocal::lib=$PERL_LL_ROOT/ > $XDG_CONFIG_DIR/zsh/02-env-perl.sh;
}

function setup_tmux() {
  lnk dotfiles/tmux.conf $HOME/.tmux.conf;
  [ -d ~/.tmux/plugins ] || mkdir -p ~/.tmux/plugins;
  [ -d ~/.tmux/plugins/tpm ] || git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

function setup_vi() {
  lnk dotfiles/vim $HOME/.vim;
  [ -e "$HOME/.vim/autoload/plug.vim" ] || run curl -sfLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  lnk dotfiles/nvim $XDG_CONFIG_DIR/nvim;
  [ -d "$XDG_DATA_HOME/nvim/site/pack/packer/start" ] \
    || git clone --depth 1 https://github.com/wbthomason/packer.nvim $XDG_DATA_HOME/nvim/site/pack/packer/start/packer.nvim;
}

function setup_zsh() {
  lnk dotfiles/shell/path.sh $XDG_CONFIG_DIR/zsh/00-path.sh;
  lnk dotfiles/shell/env.sh  $XDG_CONFIG_DIR/zsh/01-env.sh;

  lnk dotfiles/shell/aliases.sh $XDG_CONFIG_DIR/zsh/10-aliases.sh;
  lnk dotfiles/shell/bindkey.sh $XDG_CONFIG_DIR/zsh/10-bindkey.sh;
  lnk dotfiles/shell/history.sh $XDG_CONFIG_DIR/zsh/10-history.sh;

  lnk $HOMEBREW_PREFIX/etc/profile.d/z.sh $XDG_CONFIG_DIR/zsh/15-z.sh
  lnk dotfiles/shell/completion.sh $XDG_CONFIG_DIR/zsh/15-completion.sh;

  lnk dotfiles/shell/setkeylabel.sh $XDG_CONFIG_DIR/zsh/30-setkeylabel.sh;
  lnk dotfiles/shell/proxy.sh $XDG_CONFIG_DIR/zsh/50-proxy.sh
  lnk dotfiles/shell/zshrc $HOME/.zshrc;
}

function setup_zsh_theme() {
  if [ ! -d "$XDG_CONFIG_DIR/zsh/powerlevel10k" ]; then
    run git clone https://github.com/romkatv/powerlevel10k.git $XDG_CONFIG_DIR/zsh/powerlevel10k;
  fi

  lnk $XDG_CONFIG_DIR/zsh/powerlevel10k/powerlevel10k.zsh-theme $XDG_CONFIG_DIR/zsh/20-theme-powerlevel10k.sh;
  lnk dotfiles/prompt/p10k.zsh $XDG_CONFIG_DIR/zsh/21-p10k.zsh;

  lnk $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh $XDG_CONFIG_DIR/zsh/25-zsh-syntax-highlighting.zsh
  lnk dotfiles/shell/gruvbox.sh $XDG_CONFIG_DIR/zsh/25-gruvbox.sh;
}

# NOTE XDG_CONFIG_DIR != XDG_CONFIG_DIRS
XDG_CONFIG_DIR="$HOME/.config";
XDG_DATA_HOME="$HOME/.local/share";
SOURCE="$(readlink -f dotfiles)";
[ -z $SOURCE -o ! -d $SOURCE ] && abort "Cannot find ./dotfiles ($SOURCE)";
[ -d $XDG_CONFIG_DIR/zsh ] || mkdir -p $XDG_CONFIG_DIR/zsh;

setup_misc;
setup_zsh;
setup_zsh_theme;
setup_perl;
setup_tmux;
setup_vi;
