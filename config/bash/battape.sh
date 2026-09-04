BATTAPE_DB="${BATTAPE_DB:-"$HOME/.local/share/battape/battape.sqlite"}";
BATTAPE_MAX_ROWS="${BATTAPE_MAX_ROWS:-12}";
BATTAPE_CURRENT_TTY="$(tty 2>/dev/null || echo '/dev/tty')";
BATTAPE_COLOR_FAIL=$'\e[31m';
BATTAPE_COLOR_OLD=$'\e[37m';
BATTAPE_COLOR_OLDEST=$'\e[90m';
BATTAPE_COLOR_RECENT=$'\e[97m';
BATTAPE_COLOR_RESET="$(tput sgr0 2>/dev/null || printf '\e[0m')";
BATTAPE_COLOR_SELECTED=$'\e[1;97m';
BATTAPE_COLOR_SUCCESS=$'\e[32m';

__battape_cleanup() {
  stty "$stty_settings" 2>/dev/null || :;
  local i;
  printf '\e8\e[u'; # restore cursor
  for ((i = 0; i <= "$rows"; i++)); do
    printf '\e[K';
    [ "$i" -lt "$rows" ] && printf '\r\n';
  done
  printf '\e8\e[u'; # restore cursor
  tput cnorm 2>/dev/null || :;
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

__battape_read_key() {
  local byte remaining=0;

  BATTAPE_KEY="$(dd bs=1 count=1 2>/dev/null; printf x)";
  BATTAPE_KEY="${BATTAPE_KEY%x}";
  [ -n "$BATTAPE_KEY" ] || return 1;

  case "$BATTAPE_KEY" in
    [$'\xC2'-$'\xDF']) remaining=1 ;;
    [$'\xE0'-$'\xEF']) remaining=2 ;;
    [$'\xF0'-$'\xF4']) remaining=3 ;;
  esac

  while [ "$remaining" -gt 0 ]; do
    byte="$(dd bs=1 count=1 2>/dev/null; printf x)";
    byte="${byte%x}";
    [ -n "$byte" ] || return 1;
    BATTAPE_KEY+="$byte";
    ((remaining--));
  done
}

__battape_read_bracketed_paste() {
  local byte buffered="" char paste="" sanitized="" terminator=$'\e[201~';

  while :; do
    byte="$(dd bs=1 count=1 2>/dev/null; printf x)";
    byte="${byte%x}";
    [ -n "$byte" ] || break;
    buffered+="$byte";

    while [ -n "$buffered" ] && [[ "$terminator" != "$buffered"* ]]; do
      paste+="${buffered:0:1}";
      buffered="${buffered:1}";
    done
    [ "$buffered" = "$terminator" ] && break;
  done

  while [ -n "$paste" ]; do
    char="${paste:0:1}";
    paste="${paste:1}";
    if [[ "$char" =~ [[:print:]] ]]; then
      sanitized+="$char";
    elif [[ "$char" == $'\t' || "$char" == $'\r' || "$char" == $'\n' ]]; then
      sanitized+=' ';
    fi
  done
  BATTAPE_PASTED="$sanitized";
}

__battape_truncate_display() {
  local text="$1" limit="$2" char char_width escape output="" width=0;

  if [[ "$text" != *$'\e'* && "$text" != *[!\ -~]* ]]; then
    printf '%s' "${text:0:limit}";
    [ "${#text}" -le "$limit" ] || printf '%s' "$BATTAPE_COLOR_RESET";
    return;
  fi

  while [ -n "$text" ] && [ "$width" -lt "$limit" ]; do
    if [[ "$text" =~ ^$'\e'\[[0-9\;?]*[[:alpha:]~] ]]; then
      escape="${BASH_REMATCH[0]}";
      output+="$escape";
      text="${text:${#escape}}";
      continue;
    fi

    char="${text:0:1}";
    if [[ "$char" == [\ -~] ]]; then
      char_width=1;
    else
      char_width="$(printf '%s\n' "$char" | wc -L)";
    fi
    [ "$((width + char_width))" -le "$limit" ] || break;
    output+="$char";
    text="${text:1}";
    width="$((width + char_width))";
  done

  printf '%s' "$output";
  [ -z "$text" ] || printf '%s' "$BATTAPE_COLOR_RESET";
}

__battape_query_commands() {
  local limit="${2:-12}";
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
  # command. Commands from the current TTY take precedence at both ranking
  # stages, followed by recency. "git log" matches "git status && git log",
  # while only commands beginning with "git" receive the prefix-match
  # priority.
  if [ -z "$prefix" ]; then
    sql="select start, end, exit_status, display_command as command from (
      select start, end, exit_status, tty, display_command,
        row_number() over (partition by display_command order by
          case when tty = '$BATTAPE_CURRENT_TTY' then 0 else 1 end, end desc) as display_row_number
      from (
        select start, command, end, exit_status, tty,
          case when command like 'cd %' then 'cd ' || pwd else command end as display_command,
          row_number() over (partition by command order by
            case when tty = '$BATTAPE_CURRENT_TTY' then 0 else 1 end, end desc) as command_row_number
        from history
      ) where command_row_number = 1
    ) where display_row_number = 1
      order by case when tty = '$BATTAPE_CURRENT_TTY' then 0 else 1 end, end desc
      limit $limit";
  else
    sql="select start, end, exit_status, display_command as command from (
      select start, command, end, exit_status, tty, display_command,
        row_number() over (partition by display_command order by
          case when tty = '$BATTAPE_CURRENT_TTY' then 0 else 1 end, end desc) as display_row_number
      from (
        select start, command, end, exit_status, tty,
          case when command like 'cd %' then 'cd ' || pwd else command end as display_command,
          row_number() over (partition by command order by
            case when tty = '$BATTAPE_CURRENT_TTY' then 0 else 1 end, end desc) as command_row_number
        from history
        where command like '$q' escape '\\' collate nocase
      ) where command_row_number = 1
    ) where display_row_number = 1
      order by
        case when tty = '$BATTAPE_CURRENT_TTY' then 0 else 1 end,
        end desc,
        case when command like '$prefix' escape '\\' collate nocase then 0 else 1 end,
        case when exit_status = 0 then 0 else 1 end
      limit $limit";
  fi

  sqlite3 -batch -cmd '.timeout 1000' -noheader -separator "$fs" -newline "$rs" "$BATTAPE_DB" "$sql";
}

__battape_render_history_ui() {
  local age i record cmd char char_width end exit_status arrow_color text_color query_cursor_width query_start;
  [ "$cols" -gt 3 ] || cols=4;

  query_start="$query_point";
  query_cursor_width=0;
  while [ "$query_start" -gt 0 ]; do
    char="${query:query_start-1:1}";
    if [[ "$char" == [\ -~] ]]; then
      char_width=1;
    else
      char_width="$(printf '%s\n' "$char" | wc -L)";
    fi
    [ "$((query_cursor_width + char_width))" -le "$((cols - 3))" ] || break;
    ((query_start--));
    query_cursor_width="$((query_cursor_width + char_width))";
  done

  printf '\e8\e[u'; # restore cursor
  printf '? ';
  __battape_truncate_display "${query:query_start}" "$((cols - 3))";
  printf '\e[K';
  printf '\r\n';

  for ((i = 0; i < "$rows"; i++)); do
    if [ "$i" -lt "${#matches[@]}" ]; then
      record="${matches[i]}";
      IFS="$fs" read -r _ end exit_status cmd < <(printf "%s" "$record");
      cmd="${cmd//$'\e'/\\e}";
      cmd="${cmd//$'\n'/\\n}";
      cmd="${cmd//$'\r'/\\r}";
      cmd="${cmd//$'\t'/\\t}";
      text_color="$BATTAPE_COLOR_SELECTED";
      if [ "$i" -eq "$selected" ]; then
        arrow_color="$BATTAPE_COLOR_SUCCESS";
        [ "$exit_status" != 0 ] && arrow_color="$BATTAPE_COLOR_FAIL";
        printf '%s>%s %s' "$arrow_color" "$BATTAPE_COLOR_RESET" "$text_color";
        __battape_truncate_display "$cmd" "$((cols - 3))";
        printf '%s' "$BATTAPE_COLOR_RESET";
      else
        age="$((now - end))";
        if [ -z "$end" ] || [ "$age" -gt 86400 ]; then text_color="$BATTAPE_COLOR_OLDEST";
        elif [ "$age" -lt 3600 ]; then text_color="$BATTAPE_COLOR_RECENT";
        else text_color="$BATTAPE_COLOR_OLD";
        fi
        printf '  %s' "$text_color";
        __battape_truncate_display "$cmd" "$((cols - 3))";
        printf '%s' "$BATTAPE_COLOR_RESET";
      fi
    fi

    printf '\e[K';
    [ "$i" -lt $((rows - 1)) ] && printf '\r\n';
  done

  printf '\e8\e[u\e[%sC' "$((query_cursor_width + 2))"; # restore cursor to query
}

__battape_render_history_ui_start() {
  local active_signal_traps cmd col key now pos row rows cols lines;
  local fs=$'\037' rs=$'\036';
  local query="$READLINE_LINE";
  local query_point="$READLINE_POINT";
  local query_changed=1;
  local matches=();
  local selected=0;
  cols="$(tput cols 2>/dev/null || printf 80)";
  lines="$(tput lines 2>/dev/null || printf 24)";
  now="$(date +%s)";

  stty_settings="$(stty -g)" || return;
  [ "$query_point" -le "${#query}" ] || query_point="${#query}";
  [[ "$BATTAPE_MAX_ROWS" =~ ^[1-9][0-9]*$ ]] || BATTAPE_MAX_ROWS=12;
  rows="$((lines - 2))";
  [ "$rows" -gt "$BATTAPE_MAX_ROWS" ] && rows="$BATTAPE_MAX_ROWS";
  [ "$rows" -gt 0 ] || rows=1;

  active_signal_traps="$(trap -p EXIT HUP INT QUIT TERM TSTP)";
  if [ -n "$active_signal_traps" ]; then
    printf 'battape: custom signal trap already set; history search disabled\n' >&2;
    return 1;
  fi

  trap '__battape_cleanup; trap - EXIT HUP INT QUIT TERM TSTP; return' EXIT HUP INT QUIT TERM TSTP;
  tput cnorm 2>/dev/null || :;
  if ! stty raw; then
    __battape_cleanup;
    trap - EXIT HUP INT QUIT TERM TSTP;
    return 1;
  fi
  pos="$(__battape_cursor_position)";
  read -r row col < <(printf "%s" "$pos")

  # reserve space
  if [ -n "$row" ] && [ -n "$col" ]; then
    local scroll_rows=$((row + rows - lines));
    if [ "$scroll_rows" -gt 0 ]; then
      printf '\e[%sS\e[%s;%sH' "$scroll_rows" "$((row - scroll_rows))" "$col";
    fi
  fi

  printf '\e7\e[s'; # save cursor
  while :; do
    if [ "$query_changed" -eq 1 ]; then
      mapfile -d "$rs" -t matches < <(__battape_query_commands "$query" "$rows");
      [ "${#matches[@]}" -gt 0 ] || matches=("${fs}${fs}${fs}${query}");
      query_changed=0;
    fi
    [ "$selected" -ge "${#matches[@]}" ] && selected=$((${#matches[@]} - 1));
    [ "$selected" -lt 0 ] && selected=0;
    printf "%s" "$(__battape_render_history_ui)";

    __battape_read_key || break;
    key="$BATTAPE_KEY";
    case "$key" in
      $'\e')
        IFS= read -rs -t 0.05 -n 2 key < /dev/tty 2>/dev/null;
        case "$key" in
          '[A') [ "$selected" -gt 0 ] && ((selected--)) ;;
          '[B') [ "$selected" -lt $((${#matches[@]} - 1)) ] && ((selected++)) ;;
          '[C') [ "$query_point" -lt "${#query}" ] && ((query_point++)) ;;
          '[D') [ "$query_point" -gt 0 ] && ((query_point--)) ;;
          '[3')
            IFS= read -rs -t 0.05 -n 1 key < /dev/tty 2>/dev/null;
            if [ "$key" = '~' ] && [ "$query_point" -lt "${#query}" ]; then
              query="${query:0:query_point}${query:query_point+1}";
              query_changed=1;
            fi
            ;;
          '[2')
            IFS= read -rs -t 0.05 -n 3 key < /dev/tty 2>/dev/null;
            if [ "$key" = '00~' ]; then
              __battape_read_bracketed_paste;
              query="${query:0:query_point}${BATTAPE_PASTED}${query:query_point}";
              query_point="$((query_point + ${#BATTAPE_PASTED}))";
              query_changed=1;
            else
              break;
            fi
            ;;
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
        if [ "$query_point" -gt 0 ]; then
          query="${query:0:query_point-1}${query:query_point}";
          ((query_point--));
          query_changed=1;
        fi
        ;;
      $'\004')
        if [ "$query_point" -lt "${#query}" ]; then
          query="${query:0:query_point}${query:query_point+1}";
          query_changed=1;
        fi
        ;;
      $'\001') query_point=0 ;;
      $'\005') query_point="${#query}" ;;
      *)
        if [[ "$key" =~ [[:print:]] ]]; then
          query="${query:0:query_point}${key}${query:query_point}";
          ((query_point++));
          query_changed=1;
        fi
        ;;
    esac
  done

  trap - EXIT HUP INT QUIT TERM TSTP;
  __battape_cleanup;
}

__battape_record() {
  sqlite3 -cmd '.timeout 1000' "$BATTAPE_DB" <<HERE
insert into history (start, end, hostname, tty, pwd, command, exit_status) values (
  strftime('%s', 'now') - $(( SECONDS - LAST_INTERACTIVE_COMMAND_START )),
  strftime('%s', 'now'),
  '${HOSTNAME//\'/\'\'}',
  '$BATTAPE_CURRENT_TTY',
  '${PWD//\'/\'\'}',
  '$(fc -ln -1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e "s/'/\\'\\'/g")',
  $1
)
HERE
  return "$1";
}

if [[ -z "${__battape_loaded:-}" ]] \
  && ((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4))) \
  && command -v sqlite3 >/dev/null \
  && [[ -z "$(trap -p DEBUG)" ]]; then
  mkdir -p "$(dirname "$BATTAPE_DB")" 2>/dev/null || :;
  sqlite3 -batch -cmd '.timeout 1000' "$BATTAPE_DB" <<'HERE' || return
create table if not exists history (
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
    "select group_concat(name, ',') from pragma_table_info('history') where name in ('start', 'end', 'hostname', 'tty', 'pwd', 'command', 'exit_status');")";
  if [[ "$schema_columns" != 'start,end,hostname,tty,pwd,command,exit_status' ]]; then
    printf 'battape: history table has an unsupported schema; command tracking disabled\n' >&2;
    return;
  fi

  __battape_loaded=1;
  bind -m emacs -x '"\C-r":__battape_render_history_ui_start';
  bind -m vi-insert -x '"\C-r":__battape_render_history_ui_start';
  bind -m vi-command -x '"\C-r":__battape_render_history_ui_start';

  if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == 'declare -a '* ]]; then
    PROMPT_COMMAND=("__battape_record \$?" "${PROMPT_COMMAND[@]}");
  else
    PROMPT_COMMAND="__battape_record \$?;${PROMPT_COMMAND%;}";
  fi
elif [[ -z "${__battape_loaded:-}" && -n "$(trap -p DEBUG)" ]]; then
  printf 'battape: DEBUG trap already set; command tracking disabled\n' >&2;
elif [[ -z "${__battape_loaded:-}" ]] \
  && ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
  printf 'battape: Bash 4.4 or later is required; command tracking disabled\n' >&2;
fi
