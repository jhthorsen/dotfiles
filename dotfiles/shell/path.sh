function _add_path () {
  p="$1";
  [ -L "$p" ] && p=$(readlink -f $p);
  [ -d "$p" ] && export PATH="$p:$PATH";
}

for n in Cellar/ansible Cellar/git Cellar/perl lib/ruby/gems; do
  if [ -d "$HOMEBREW_PREFIX/$n" ]; then
    version=$(ls $HOMEBREW_PREFIX/$n | sort | tail -n1);
    _add_path "$HOMEBREW_PREFIX/$n/$version/bin";
  fi
done

_add_path "$HOMEBREW_PREFIX/opt/gettext/bin";
_add_path "$HOMEBREW_PREFIX/opt/python/libexec/bin";
_add_path "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin";
_add_path "$HOMEBREW_PREFIX/opt/icu4c/bin";
_add_path "$HOMEBREW_PREFIX/opt/icu4c/sbin";
_add_path "$HOMEBREW_PREFIX/opt/ruby/bin";
_add_path "$HOMEBREW_PREFIX/opt/sqlite/bin";
_add_path "$HOMEBREW_PREFIX/opt/openssl/bin";
_add_path "$HOMEBREW_PREFIX/opt/ncurses/bin";
_add_path "$HOMEBREW_PREFIX/opt/go/libexec/bin";
_add_path "$HOMEBREW_PREFIX/bin";
_add_path "$HOMEBREW_PREFIX/sbin";
_add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
_add_path "$(readlink -f $(dirname $ZSH_SOURCE)/../../bin)";
