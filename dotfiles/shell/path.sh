function _add_path () {
  [ -d "$1" ] && export PATH="$1:$PATH";
}

for app in ansible git perl; do
  if [ -d "$HOMEBREW_CELLAR/$app" ]; then
    version=$(ls $HOMEBREW_CELLAR/$app | sort | tail -n1);
    _add_path "$HOMEBREW_CELLAR/$app/$version/bin";
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
