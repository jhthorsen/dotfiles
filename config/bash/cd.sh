# Use the directories recorded by battape as a fallback for `cd`.  Normal Bash
# path resolution always wins, so `cd ..`, `cd /tmp`, CDPATH, and existing
# relative paths retain their usual behaviour.

BATTAPE_DB="${BATTAPE_DB:-"$HOME/.local/share/battape/battape.sqlite"}";

__battape_cd_osc7() {
  printf '\e]7;file://%s%s\a' "$HOSTNAME" "$PWD";
}

__battape_cd_find() {
  local query="$1" q="%" term sql;
  local query_glob="${query//\'/\'\'}";
  local -a terms;

  # Terms match in order, as they do in battape's command search.  Quote both
  # SQL and LIKE metacharacters because the query comes from the command line.
  read -r -a terms < <(printf '%s' "$query");
  for term in "${terms[@]}"; do
    term="${term//\\/\\\\}";
    term="${term//%/\\%}";
    term="${term//_/\\_}";
    term="${term//\'/\'\'}";
    q+="$term%";
  done
  [ "$q" = '%' ] && return;

  # A command run in a directory counts as a visit.  Its score combines
  # frequency with a modest recency boost, while a final shell-side -d check
  # skips directories that have since disappeared.
  sql="select pwd from history
    where pwd like '$q' escape '\\' collate nocase
    group by pwd
    order by case when pwd glob '*/${query_glob}*'
                   and pwd not glob '*/${query_glob}*/*' then 0 else 1 end,
      count(*) * (1.0 + 1.0 / (1.0 +
      (strftime('%s', 'now') - max(end)) / 1209600.0)) desc,
      max(end) desc
    limit 20";

  while IFS= read -r directory; do
    [ -d "$directory" ] && {
      printf '%s' "$directory";
      return;
    }
  done < <(sqlite3 -readonly -batch -cmd '.timeout 1000' -noheader "$BATTAPE_DB" "$sql" 2>/dev/null);
}

cd() {
  local directory;

  # Let Bash handle a real path first.  Suppressing its failure lets an absent
  # path such as `cd dotfiles` be resolved from battape instead.
  if builtin cd "$@" 2>/dev/null; then
    __battape_cd_osc7;
    return;
  fi

  # Options and a literal `-` have Bash-specific meanings and should not be
  # interpreted as a battape search.
  if [ "$#" -eq 1 ] && [[ "$1" != - && "$1" != -* ]]; then
    directory="$(__battape_cd_find "$1")";
    if [ -n "$directory" ] && builtin cd -- "$directory"; then
      __battape_cd_osc7;
      return;
    fi
  fi

  # Re-run the builtin to display its normal diagnostic and status.
  builtin cd "$@";
}
