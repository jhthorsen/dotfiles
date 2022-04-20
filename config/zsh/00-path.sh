for n in Cellar/ansible Cellar/git Cellar/perl lib/ruby/gems; do
  if [ -d "$HOMEBREW_PREFIX/$n" ]; then
    version=$(ls $HOMEBREW_PREFIX/$n | sort | tail -n1);
    PATH="$HOMEBREW_PREFIX/$n/$version/bin:$PATH";
  fi
done

PATH="$HOMEBREW_PREFIX/opt/gettext/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/python/libexec/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/icu4c/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/icu4c/sbin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/openssl/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/ncurses/bin:$PATH";
PATH="$HOMEBREW_PREFIX/opt/go/libexec/bin:$PATH";
PATH="$HOMEBREW_PREFIX/bin:$PATH";
PATH="$HOMEBREW_PREFIX/sbin:$PATH";
PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"
PATH="$(readlink -f $(dirname $ZSH_SOURCE)/../../bin):$PATH";

# Clean up the $PATH
PATH=$(echo $PATH | perl -MList::Util=uniq -pe'$_ = join ":", grep { length && -d } uniq split ":"');
