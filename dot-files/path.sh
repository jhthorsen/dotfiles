function _add_path () {
  [ -d "$1" ] && export PATH="$1:$PATH";
}

for app in ansible git perl; do
  if [ -d "/usr/local/Cellar/$app" ]; then
    version=$(ls /usr/local/Cellar/$app | sort | tail -n1);
    _add_path "/usr/local/Cellar/$app/$version/bin";
  fi
done

_add_path "/usr/local/opt/gettext/bin";
_add_path "/usr/local/opt/python/libexec/bin";
_add_path "/usr/local/opt/coreutils/libexec/gnubin";
_add_path "/usr/local/opt/icu4c/bin";
_add_path "/usr/local/opt/icu4c/sbin";
_add_path "/usr/local/opt/ruby/bin";
_add_path "/usr/local/opt/sqlite/bin";
_add_path "/usr/local/opt/openssl/bin";
_add_path "/usr/local/opt/ncurses/bin";
_add_path "/usr/local/opt/go/libexec/bin";
_add_path "/usr/local/bin";
_add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
_add_path "$HOME/.config/dot-files/bin";
