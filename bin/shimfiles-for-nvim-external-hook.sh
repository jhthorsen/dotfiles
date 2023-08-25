#!/bin/bash
[ -z "$SHIMFILES_REMOTE_HOSTNAME" ] && SHIMFILES_REMOTE_HOSTNAME="SHIMFILES_REMOTE_HOSTNAME";
[ -z "$SHIMFILES_REMOTE_PATH" ] && SHIMFILES_REMOTE_PATH="/home/$USER/Documents";
[ -z "$SHIMFILES_IGNORE_FILES" ] && SHIMFILES_IGNORE_FILES="local/";
[ -z "$SHIMFILES_TMPFILE" ] && SHIMFILES_TMPFILE="/tmp/$USER.nvim-external-hook.tmp";

[ -n "$DRY_RUN" ] && DRY_RUN="echo";
[ -n "$DRY_RUN" ] && SHIMFILES_TMPFILE="/dev/null";

function absolute_path() {
  local path="$1";
  local file="";
  if [ ! -d "$path" ]; then file="/$(basename "$path")"; path="$(dirname "$path")"; fi
  cd "$path" > /dev/null || exit 2;
  echo "$(pwd)$file"; # return string
  cd - > /dev/null || exit 2;
}

function command_nvim_event() {
  local event="$1";
  local local_path; local_path="$(absolute_path "$2")";

  [ -f "$local_path" ] && [ -r "$local_path" ] || exit 2;
  echo "$local_path" | grep -q "/.git/" && exit 0;

  local project_path; project_path="$(find_project_path "$local_path")";
  local project_name; project_name="$(basename "$project_path")";
  local rel_path="${local_path#"$project_path"}";
  local rel_path="${rel_path%"/"}";
  local local_dir; local_dir="$(dirname "$local_path")";
  [ -n "$project_name" ] || exit 2;

  if [ "$event" = "BufReadPre" ]; then
    $DRY_RUN touch "$SHIMFILES_TMPFILE";
    $DRY_RUN chmod 600 "$SHIMFILES_TMPFILE";
    [ -d "$local_dir" ] || mkdir -p "$local_dir";
    ssh_with_mux "cat $SHIMFILES_REMOTE_PATH/$project_name$rel_path" > "$SHIMFILES_TMPFILE";
    $DRY_RUN mv "$SHIMFILES_TMPFILE" "$local_path";
    exit 35;
  elif [ "$event" = "BufWritePost" ]; then
    ssh_with_mux "cat - > $SHIMFILES_REMOTE_PATH/$project_name$rel_path" < "$local_path";
    exit "$?";
  fi
}

function command_shim() {
  local project_name; project_name="$(basename "$PWD")";
  touch '.shim';
  ssh_with_mux "cd $SHIMFILES_REMOTE_PATH/$project_name && find . -type f | grep -v '$SHIMFILES_IGNORE_FILES\|.git'" | while read -r rel; do
    dir="$(dirname "$rel")";
    [ -d "$dir" ] || mkdir -p "$dir";
    echo "- $rel";
    echo "Loading $rel ..." > "$rel";
  done
  exit "$?";
}

function command_usage() {
  echo "Usage: shimfiles-for-nvim-external-hook.sh [shim|BufReadPre|BufWritePost]";
  exit 2;
}

function find_project_path() {
  local project_path="$1";
  local rel="";
  while [ "$project_path" != "/" ]; do
    rel="/$(basename "$project_path")$rel";
    project_path="$(dirname "$project_path")";
    [ -e "$project_path/.shim" ] || continue;
    echo "$project_path"; # return string
    return 0;
  done

  return 1;
}

function ssh_with_mux() {
  if [ -n "$DRY_RUN" ]; then
    echo "ssh -C $SHIMFILES_REMOTE_HOSTNAME $*" >&2;
    return 0;
  fi

  [ -z "$SHIMFILES_REMOTE_HOSTNAME" ] && exit 1;
  ps axf | grep -q "[s]sh.*$SHIMFILES_REMOTE_HOSTNAME" || exit 1;
  ssh -C "$SHIMFILES_REMOTE_HOSTNAME" "$@" || exit "$?";
}

if [ "$1" = "shim" ]; then
  command_shim;
elif [ "$1" = "BufReadPre" ] || [ "$1" = "BufWritePost" ]; then
  command_nvim_event "$@";
else
  command_usage;
fi
