#!/bin/bash
ack() {
  local -a args;
  local bin;

  bin="$(command -v rg)";
  if [ -n "$bin" ]; then
    while [ -n "$*" ]; do case "$1" in
      -L) args+=("--files-without-match"); shift ;;
      *) args+=("$1"); shift ;;
    esac done

    $DRY_RUN "$bin" "${args[@]}";
    return "$?";
  fi

  bin="$(command -v ack || command -v ack-grep)";
  if [ -n "$bin" ]; then
    $DRY_RUN "$bin" "$@";
    return "$?";
  fi

  # TODO Translate arguments to grep
  bin="grep";
  $DRY_RUN "$bin" "$@";
  return "$?";
}

acke() {
  vi $(ack -l "$@")
}

f() {
  if command -v fd &>/dev/null; then
    if [ -d "$1" ]; then
      fd -H -E .git . "$@";
    else
      fd -H -E .git "$@";
    fi
  else
    local -a args;
    if [ -z "$1" ] || [ ! -e "$1" ]; then args=( . ); fi
    args+=( "$@" );
    for exclude in ".git" ".vscode" "node_modules" "dist" "target"; do
      args+=( -not -path "*/$exclude/*" );
    done
    find "${args[@]}" -mindepth 1 | sed 's|^\./||' | sort;
  fi
}

git() {
  if [ -z "$*" ]; then command git status -bs; return "$?"; fi
  if [ "$1" = "push" ]; then shift; $DOTFILES_HOME/bin/git-push.sh "$@"; return "$?"; fi
  if [ ! -t 0 ]; then command git "$@"; return "$?"; fi
  if ! command -v diffu >/dev/null; then command git "$@"; return "$?"; fi
  PAGER="diffu" command git "$@";
}

perlclean() {
  runv make clean;
  for f in Changes.bak Makefile META.json META.yml; do [ -e "$f" ] && runv rm "$f"; done
  runv rm *.tar.gz 2>/dev/null;
}

perldist() {
  command -v cpan-upload >/dev/null || cpanm -n CPAN::Uploader;
  command -v pod2markdown >/dev/null || cpanm -n Pod::Markdown;

  perlclean;
  runv git diff --quiet && runv git diff --cached --quiet || return "$?";
  runv git pull origin || return "$?";

  local main_pm_file="$(grep ABSTRACT_FROM Makefile.PL | cut -d\' -f 2 | head -n1)";
  local version="$(grep '[0-9]T[0-9]' ./Changes | head -n1 | awk '{print $1}')";
  runv git rev-parse -q --verify "refs/tags/v$version" && return 1;
  runv grep -i "Not Released" Changes && return 1;

  runv find ./lib -type f -name '*pm' -exec sed -i '' -e "s/our[ ].*\$VERSION[ ]*=.*/our \$VERSION = '$version';/" '{}' \;
  runv pod2markdown "$main_pm_file" > README.md || return "$?";
  [ "$(git rev-list --count origin/$(git rev-parse --abbrev-ref HEAD)..HEAD)" -gt 0 ] \
    && runv git commit -a --amend;

  runv perl Makefile.PL && runv make all && runv make manifest && runv make dist || return "$?";
  local tar="$(ls *.tar.gz)";
  runv tar -tzf "$tar" || return "$?";

  read -r -p "Do you want to run 'cpan-upload $tar' [y/N]? " answer;
  [[ "$answer" =~ ^[Yy]$ ]] \
    && runv git tag "v$version" && runv cpan-upload "$tar" || return "$?";
  runv git push origin --tags;
  runv git push origin;
  perlclean;
}

runv() {
  echo "$(tput setaf 2)\$ $*$(tput sgr0)" >&2
  "$@";
}

reload() {
  "$DOTFILES_HOME/config/bash/generate.sh" "$DOTFILES_HOME/config/bash/bashrc.sh" > "$HOME/.bashrc";
  "$DOTFILES_HOME/config/bash/generate.sh" "$DOTFILES_HOME/config/bash/bash_profile.sh" > "$HOME/.bash_profile";
  echo "Reloading bash v$BASH_VERSION";
  exec bash --login;
}

vi() {
  [ -d ".git" ] && tt start --quiet --resume;
  if [ -n "$*" ]; then nvim "$@";
  else nvim -c ':lua require("batphone.util").startup()';
  fi
  [ -d ".git" ] && tt stop --quiet --tag-unless-same-project;
}
