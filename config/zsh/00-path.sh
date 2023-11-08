PATH="$HOME/.cargo/bin";
PATH="/bin:$PATH";
PATH="/sbin:$PATH";
PATH="/usr/bin:$PATH";
PATH="/usr/sbin:$PATH";
PATH="/usr/local/sbin:$PATH";
PATH="/usr/local/bin:$PATH";

PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/python/libexec/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/go/libexec/bin:$PATH";
#PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/gettext/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/ncurses/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/openssl/bin:$PATH";
PATH="$HOMEBREW_PREFIX/bin:$PATH";
PATH="$HOMEBREW_PREFIX/sbin:$PATH";

for dir in lib/ruby/gems Cellar/perl; do
  dir="$HOMEBREW_PREFIX/$dir";
  [ -d "$dir" ] || continue;
  for version in $(find "$dir" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort -V); do
    PATH="$dir/$version/bin:$PATH";
  done
done

export PNPM_HOME="$HOME/Library/pnpm";
PATH="$PNPM_HOME:$PATH";

[ -n "$(command -v xcode-select)" ] \
  && PATH="$(xcode-select --print-path)/usr/bin:$PATH";

PATH="$(readlink_f "$(dirname "$ZSH_SOURCE")/../../bin"):$PATH";

# Clean, sort, remove invalid entries in the $PATH
PATH="$(echo "$PATH" | perl -pe'$_ = join ":", grep { !$u{$_}++ && length && -d } split ":"')";
export PATH;
