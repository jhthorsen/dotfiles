BATTAPE_DB="${BATTAPE_DB:-"$HOME/.bash_command_history.db"}";
BATTAPE_MAX_ROWS="${BATTAPE_MAX_ROWS:-12}";
BATTAPE_COLOR_FAIL=$'\e[31m';
BATTAPE_COLOR_OLD=$'\e[37m';
BATTAPE_COLOR_OLDEST=$'\e[90m';
BATTAPE_COLOR_RECENT=$'\e[97m';
BATTAPE_COLOR_RESET="$(tput sgr0 2>/dev/null || printf '\e[0m')";
BATTAPE_COLOR_SELECTED=$'\e[1;97m';
BATTAPE_COLOR_SUCCESS=$'\e[32m';

__battape_cleanup() {
  stty "$BATTAPE_STTY_SETTINGS";
  local i;
  printf '\e8\e[u'; # restore cursor
  for ((i = 0; i <= "$BATTAPE_ROWS"; i++)); do
    printf '\e[K';
    [ "$i" -lt "$BATTAPE_ROWS" ] && printf '\r\n';
  done
  printf '\e8\e[u'; # restore cursor
  tput cnorm 2>/dev/null;
}

__battape_cursor_position() {
  local delimiter=R response pattern=$'\e''\[([0-9]+);([0-9]+)R';
  printf '\e[6n' > /dev/tty 2>/dev/null || return;
  IFS= read -rs -t 0.1 -d "$delimiter" response < /dev/tty 2>/dev/null || return;
  response+="R";
  [[ "$response" =~ $pattern ]] && printf '%s %s' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}";
}

__battape_match_command() {
  local record="$1" i;
  for ((i = 0; i < 3; i++));
    do record="${record#*"$fs"}";
  done
  printf '%s' "$record";
}

__battape_query_commands() {
  local limit="${2:-12}";
  local prefix="" q="%" term sql;
  local -a terms;

  # Each whitespace-separated term becomes a literal LIKE fragment. The
  # surrounding percent signs allow other text between terms, but preserve
  # their order: "git log" matches "git status && git log", not "log git".
  read -r -a terms < <(printf "%s" "$1")
  for term in "${terms[@]}"; do
    term="${term//\\/\\\\}";
    term="${term//%/\\%}";
    term="${term//_/\\_}";
    term="${term//\'/\'\'}";
    q+="$term%";
    prefix+="$term%";
  done

  # Search before ranking duplicates, then retain the newest row for each
  # command. Prefix matches rank first, followed by successful commands and
  # then recency. "git log" matches "git status && git log", while only
  # commands beginning with "git" receive the prefix-match priority.
  if [ -z "$prefix" ]; then
    sql="select id, end, exit_status, command from (
      select id, command, end, exit_status,
        row_number() over (partition by command order by end desc, id desc) as row_number
      from history
    ) where row_number = 1
      order by end desc, id desc
      limit $limit";
  else
    sql="select id, end, exit_status, command from (
      select id, command, end, exit_status,
        row_number() over (partition by command order by end desc, id desc) as row_number
      from history
      where command like '$q' escape '\\' collate nocase
    ) where row_number = 1
      order by
        case when command like '$prefix' escape '\\' collate nocase then 0 else 1 end,
        case when exit_status = 0 then 0 else 1 end,
        end desc,
        id desc
      limit $limit";
  fi

  sqlite3 -batch -cmd '.timeout 1000' -noheader -separator "$fs" \
    -newline "$rs" "$BATTAPE_DB" "$sql";
}

__battape_render_history_ui() {
  local age i record cmd end exit_status arrow_color text_color;
  [ "$cols" -gt 3 ] || cols=4;

  printf '\e8\e[u'; # restore cursor
  printf '%s%s' "$prompt" "${query:0:$((cols - 3))}";
  printf '\e[K';
  printf '\r\n';

  for ((i = 0; i < "$BATTAPE_ROWS"; i++)); do
    if [ "$i" -lt "${#matches[@]}" ]; then
      record="${matches[i]}";
      IFS="$fs" read -r _ end exit_status cmd < <(printf "%s" "$record");
      cmd="${cmd//$'\e'/\\e}";
      cmd="${cmd//$'\n'/\\n}";
      cmd="${cmd//$'\r'/\\r}";
      cmd="${cmd//$'\t'/\\t}";
      cmd="${cmd:0:$((cols - 3))}";
      text_color="$BATTAPE_COLOR_SELECTED";
      if [ "$i" -eq "$selected" ]; then
        arrow_color="$BATTAPE_COLOR_SUCCESS";
        [ "$exit_status" != 0 ] && arrow_color="$BATTAPE_COLOR_FAIL";
        printf '%s>%s %s%s%s' "$arrow_color" "$BATTAPE_COLOR_RESET" "$text_color" "$cmd" "$BATTAPE_COLOR_RESET";
      else
        age="$((now - end))";
        if [ -z "$end" ] || [ "$age" -gt 86400 ]; then text_color="$BATTAPE_COLOR_OLDEST";
        elif [ "$age" -lt 3600 ]; then text_color="$BATTAPE_COLOR_RECENT";
        else text_color="$BATTAPE_COLOR_OLD";
        fi
        printf '  %s%s%s' "$text_color" "$cmd" "$BATTAPE_COLOR_RESET";
      fi
    fi

    printf '\e[K';
    [ "$i" -lt $((BATTAPE_ROWS - 1)) ] && printf '\r\n';
  done
}

__battape_render_history_ui_start() {
  local cmd col key now pos row cols lines;
  local fs=$'\037' rs=$'\036';
  local prompt="${PS1@P}";
  local query="$READLINE_LINE";
  local query_changed=1;
  local matches=();
  local selected=0;
  cols="$(tput cols 2>/dev/null || printf 80)";
  lines="$(tput lines 2>/dev/null || printf 24)";
  now="$(date +%s)";

  BATTAPE_STTY_SETTINGS="$(stty -g)" || return;
  [[ "$BATTAPE_MAX_ROWS" =~ ^[1-9][0-9]*$ ]] || BATTAPE_MAX_ROWS=12;
  BATTAPE_ROWS="$((lines - 2))";
  [ "$BATTAPE_ROWS" -gt "$BATTAPE_MAX_ROWS" ] && BATTAPE_ROWS="$BATTAPE_MAX_ROWS";
  [ "$BATTAPE_ROWS" -gt 0 ] || BATTAPE_ROWS=1;

  trap '__battape_cleanup; trap - INT; return' INT;
  tput civis 2>/dev/null;
  stty raw;
  pos="$(__battape_cursor_position)";
  read -r row col < <(printf "%s" "$pos")

  # reserve space
  if [ -n "$row" ] && [ -n "$col" ]; then
    local scroll_rows=$((row + BATTAPE_ROWS - lines));
    if [ "$scroll_rows" -gt 0 ]; then
      printf '\e[%sS\e[%s;%sH' "$scroll_rows" "$((row - scroll_rows))" "$col";
    fi
  fi

  printf '\e7\e[s'; # save cursor
  while :; do
    if [ "$query_changed" -eq 1 ]; then
      mapfile -d "$rs" -t matches < <(__battape_query_commands "$query" "$BATTAPE_ROWS");
      [ "${#matches[@]}" -gt 0 ] || matches=("${fs}${fs}${fs}${query}");
      query_changed=0;
    fi
    [ "$selected" -ge "${#matches[@]}" ] && selected=$((${#matches[@]} - 1));
    [ "$selected" -lt 0 ] && selected=0;
    __battape_render_history_ui;

    key="$(dd bs=1 count=1 2>/dev/null; printf x)";
    key="${key%x}";
    [ -n "$key" ] || break;
    case "$key" in
      $'\e')
        IFS= read -rs -t 0.05 -n 2 key < /dev/tty 2>/dev/null;
        case "$key" in
          '[A') [ "$selected" -gt 0 ] && ((selected--)) ;;
          '[B') [ "$selected" -lt $((${#matches[@]} - 1)) ] && ((selected++)) ;;
          *) break ;;
        esac
        ;;
      $'\003') break ;;
      $'\r')
        if [ "${#matches[@]}" -gt 0 ]; then
          cmd="$(__battape_match_command "${matches[selected]}")";
          READLINE_LINE="$cmd";
          READLINE_POINT="${#READLINE_LINE}";
        fi
        break
        ;;
      $'\n')
        [ "$selected" -lt $((${#matches[@]} - 1)) ] && ((selected++))
        ;;
      $'\v')
        [ "$selected" -gt 0 ] && ((selected--))
        ;;
      $'\177'|$'\b')
        if [ -n "$query" ]; then
          query="${query:0:${#query}-1}";
          query_changed=1;
        fi
        ;;
      *)
        if [[ "$key" =~ [[:print:]] ]]; then
          query+="$key";
          query_changed=1;
        fi
        ;;
    esac
  done

  trap - INT;
  __battape_cleanup;
}

__battape_record() {
  local status="${1:-255}";
  local hostname="${HOSTNAME//\'/\'\'}";
  local tty;
  local pwd="${PWD//\'/\'\'}";
  local command="${LAST_INTERACTIVE_COMMAND//\'/\'\'}";

  tty="$(tty)";
  tty="${tty//\'/\'\'}";
  LAST_INTERACTIVE_COMMAND_STATUS="$status";
  [[ "$LAST_INTERACTIVE_COMMAND" == __battape* ]] && return "$status";
  [[ -z "$LAST_INTERACTIVE_COMMAND" ]] && return "$status";
  sqlite3 -cmd '.timeout 1000' "$BATTAPE_DB" <<HERE
insert into history (start, end, hostname, tty, pwd, command, exit_status)
values (
  strftime('%s', 'now') - $(( SECONDS - LAST_INTERACTIVE_COMMAND_SECONDS )),
  strftime('%s', 'now'),
  '$hostname',
  '$tty',
  '$pwd',
  '$command',
  $LAST_INTERACTIVE_COMMAND_STATUS
)
HERE
  return "$status";
}

__battape_track_command() {
  local cmd="$BASH_COMMAND";
  [[ "$cmd" == _* ]] && return;
  LAST_INTERACTIVE_COMMAND="$cmd";
  LAST_INTERACTIVE_COMMAND_SECONDS="$SECONDS";
  BASH_COMMAND="$cmd";
}

if [[ -z "${__battape_loaded:-}" ]] \
  && ((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4))) \
  && command -v sqlite3 >/dev/null \
  && [[ (-e "$BATTAPE_DB" && -w "$BATTAPE_DB") || (! -e "$BATTAPE_DB" && -w "$(dirname "$BATTAPE_DB")") ]] \
  && [[ -z "$(trap -p DEBUG)" ]]; then
  sqlite3 -batch -cmd '.timeout 1000' "$BATTAPE_DB" <<'HERE' || return
create table if not exists history (
  id integer primary key autoincrement,
  start integer not null,
  end integer not null,
  hostname text not null,
  tty text not null,
  pwd text not null,
  command text not null,
  exit_status integer not null
);
create index if not exists idx_history_end on history(end);
HERE

  schema_columns="$(sqlite3 -batch -noheader "$BATTAPE_DB" \
    "select group_concat(name, ',') from pragma_table_info('history');")";
  if [[ "$schema_columns" != 'id,start,end,hostname,tty,pwd,command,exit_status' ]]; then
    printf 'battape: history table has an unsupported schema; command tracking disabled\n' >&2;
    return;
  fi

  __battape_loaded=1;
  bind -m emacs -x '"\C-r":__battape_render_history_ui_start';
  bind -m vi-insert -x '"\C-r":__battape_render_history_ui_start';
  bind -m vi-command -x '"\C-r":__battape_render_history_ui_start';

  PROMPT_COMMAND="__battape_record \$?;${PROMPT_COMMAND%;}";
  trap '__battape_track_command' DEBUG;
elif [[ -z "${__battape_loaded:-}" && -n "$(trap -p DEBUG)" ]]; then
  printf 'battape: DEBUG trap already set; command tracking disabled\n' >&2;
elif [[ -z "${__battape_loaded:-}" ]] \
  && ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
  printf 'battape: Bash 4.4 or later is required; command tracking disabled\n' >&2;
fi
