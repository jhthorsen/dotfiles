[ -z "$1" ] && exec echo "Usage: $0 {bashrc,bash_profile}";

export DOTFILES_HOME="${DOTFILES_HOME:-"$HOME/git/dotfiles"}";
export HOMEBREW_PREFIX="$(/opt/homebrew/bin/brew --prefix 2>/dev/null)";

[ -r "$HOME/.config/shell/fzf-key-bindings.bash" ] \
  || curl -Ls "https://github.com/junegunn/fzf/raw/master/shell/key-bindings.bash" > "$HOME/.config/shell/fzf-key-bindings.bash";
[ -r "$HOME/.config/shell/fzf-completion.bash" ] \
  || curl -Ls "https://github.com/junegunn/fzf/raw/master/shell/completion.bash" > "$HOME/.config/shell/fzf-completion.bash";

generate_bash_functions() {
  grep "^[a-z]\+()" "$DOTFILES_HOME/config/bash/bash_functions.sh" | cut -d"(" -f1 | while read -r f; do
    echo "$f() { source \"$DOTFILES_HOME/config/bash/bash_functions.sh\"; $f \"\$@\"; };";
  done
}

generate_gpg_config() {
  command -v gpgconf >/dev/null || return;
  echo "export SSH_AUTH_SOCK=\"$(gpgconf --list-dirs agent-ssh-socket)\";";
  echo "(&>/dev/null gpgconf --launch gpg-agent &);";
}

generate_paths() {
  command -v xcode-select >/dev/null && PATH="$(xcode-select --print-path)/usr/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/gettext/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/ncurses/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/openssl/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/sqlite/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/go/libexec/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/python/libexec/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/ruby/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/opt/perl/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/bin:$PATH";
  [ -n "$HOMEBREW_PREFIX" ] && PATH="$HOMEBREW_PREFIX/sbin:$PATH";
  [ -d "$HOME/.cargo/bin" ] && PATH="$HOME/.cargo/bin:$PATH";
  [ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH";

  PATH="$DOTFILES_HOME/bin:$PATH";
  PATH="$(perl -e 'print join ":",grep{!$u{$_}++&&-e&&length}split ":",$ENV{PATH}')";
  export PATH;

  [ -n "$XDG_CONFIG_DIR" ] \
    && echo "export XDG_CONFIG_DIR=\"$XDG_CONFIG_DIR\";" \
    || echo 'export XDG_CONFIG_DIR="$HOME/.config";';
  [ -n "$HOMEBREW_PREFIX" ] \
    && echo "export HOMEBREW_PREFIX=\"$HOMEBREW_PREFIX\";";
  echo "export DOTFILES_HOME=\"$DOTFILES_HOME\";";
  echo "export PATH=\"$PATH\";";
}

while read -r line; do
  comment="$(echo "$line" | awk -F ' # ' '{print $2}')";
  if [ "$comment" = "INLINE" ]; then
    condition="$(echo "$line" | awk -F ' && ' '{print $1}')";
    statement="$(echo "$line" | sed 's/^.* && //')";
    if eval "$condition"; then
      echo "$statement" | sed 's/INLINE/generated/';
    else
      echo "# $statement" | sed 's/INLINE/generated/';
    fi
    continue;
  fi

  read_from="$(echo "$line" | awk -F '# read:' '{print $2}')";
  if [ -n "$read_from" ]; then
    $read_from "$line";
    continue;
  fi

  echo "$line";
done < "$1";

echo "Generated $1" >&2
