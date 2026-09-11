BATTAPE_DATA_HOME="${BATTAPE_DATA_HOME:-"${XDG_DATA_HOME:-"$HOME/.local/share"}/battape"}";
BATTAPE_DB="${BATTAPE_DB:-"$BATTAPE_DATA_HOME/battape.sqlite"}";

BATTAPE_HISTORY_MAX_ROWS="${BATTAPE_HISTORY_MAX_ROWS:-12}";
BATTAPE_HISTORY_COLOR_FAIL="${BATTAPE_HISTORY_COLOR_FAIL:-$'\e[31m'}";
BATTAPE_HISTORY_COLOR_OLD="${BATTAPE_HISTORY_COLOR_OLD:-$'\e[37m'}";
BATTAPE_HISTORY_COLOR_OLDEST="${BATTAPE_HISTORY_COLOR_OLDEST:-$'\e[90m'}";
BATTAPE_HISTORY_COLOR_RECENT="${BATTAPE_HISTORY_COLOR_RECENT:-$'\e[97m'}";
BATTAPE_HISTORY_COLOR_RESET="${BATTAPE_HISTORY_COLOR_RESET:-$(tput sgr0 2>/dev/null || printf '\e[0m')}";
BATTAPE_HISTORY_COLOR_SELECTED="${BATTAPE_HISTORY_COLOR_SELECTED:-$'\e[1;97m'}";
BATTAPE_HISTORY_COLOR_SUCCESS="${BATTAPE_HISTORY_COLOR_SUCCESS:-$'\e[32m'}";

BATTAPE_PROMPT_COLOR_BG=${BATTAPE_PROMPT_COLOR_BG:-'\[\e[48;2;48;48;48m\]'};
BATTAPE_PROMPT_COLOR_BG_RESET=${BATTAPE_PROMPT_COLOR_BG_RESET:-'\[\e[49m\]'};
BATTAPE_PROMPT_COLOR_MAGENTA=${BATTAPE_PROMPT_COLOR_MAGENTA:-'\[\e[35m\]'};
BATTAPE_PROMPT_COLOR_SEPARATOR=${BATTAPE_PROMPT_COLOR_SEPARATOR:-'\[\e[38;2;48;48;48m\]'};
BATTAPE_PROMPT_COLOR_RED=${BATTAPE_PROMPT_COLOR_RED:-'\[\e[31m\]'};
BATTAPE_PROMPT_COLOR_RESET=${BATTAPE_PROMPT_COLOR_RESET:-'\[\e[0m\]'};
BATTAPE_PROMPT_COLOR_FG=${BATTAPE_PROMPT_COLOR_FG:-'\[\e[38;2;2;175;215m\]'};
BATTAPE_PROMPT_COLOR_HOST=${BATTAPE_PROMPT_COLOR_HOST:-$BATTAPE_PROMPT_COLOR_FG};
BATTAPE_PROMPT_HOST=${BATTAPE_PROMPT_HOST:-auto};
BATTAPE_PROMPT_PATH_DEPTH=${BATTAPE_PROMPT_PATH_DEPTH:-3};
BATTAPE_PROMPT_GIT=${BATTAPE_PROMPT_GIT:-1};
BATTAPE_PROMPT_SUCCESS=${BATTAPE_PROMPT_SUCCESS:-✓};
BATTAPE_PROMPT_FAILURE=${BATTAPE_PROMPT_FAILURE:-✗};
BATTAPE_PROMPT_SEPARATOR=${BATTAPE_PROMPT_SEPARATOR:-};
BATTAPE_CD_OSC7=${BATTAPE_CD_OSC7:-auto};
BATTAPE_CD_RECENCY_DAYS=${BATTAPE_CD_RECENCY_DAYS:-14};

# Bash before 5.3 can occasionally leave readline's terminal mode in raw,
# no-echo state.  Newer Bash releases do not need this prompt-time check.
if ((BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3))); then
  BATTAPE_TTY_FIX="${BATTAPE_TTY_FIX:-icanon echo isig icrnl opost}";
fi

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
    [ "${#text}" -le "$limit" ] || printf '%s' "$BATTAPE_HISTORY_COLOR_RESET";
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
  [ -z "$text" ] || printf '%s' "$BATTAPE_HISTORY_COLOR_RESET";
}

__battape_query_commands() {
  local limit="${2:-12}" q="" prefix="" term;
  local -a terms;

  # Each whitespace-separated term becomes a literal LIKE fragment. Percent
  # signs around every term allow matches anywhere in the command, while
  # preserving their order: "git log" matches "git status && git log", not
  # "log git".
  read -r -a terms < <(printf "%s" "$1")
  for term in "${terms[@]}"; do
    term="${term//\\/\\\\}";
    term="${term//%/\\%}";
    term="${term//_/\\_}";
    term="${term//\'/\'\'}";
    q+="%$term%";
    # Commands beginning with the first search word rank ahead of other
    # matches. The general query above still permits that word in the middle.
    [ -n "$prefix" ] || prefix="$term%";
  done

  # Search before ranking duplicates, then retain the newest row for each
  # command. Commands from the current TTY take precedence at both ranking
  # stages. For a nonempty query, a command beginning with the first word
  # ranks ahead of other matches, then recency breaks ties.
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
        case when command like '$prefix' escape '\\' collate nocase then 0 else 1 end,
        end desc,
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
      text_color="$BATTAPE_HISTORY_COLOR_SELECTED";
      if [ "$i" -eq "$selected" ]; then
        arrow_color="$BATTAPE_HISTORY_COLOR_SUCCESS";
        [ "$exit_status" != 0 ] && arrow_color="$BATTAPE_HISTORY_COLOR_FAIL";
        printf '%s>%s %s' "$arrow_color" "$BATTAPE_HISTORY_COLOR_RESET" "$text_color";
        __battape_truncate_display "$cmd" "$((cols - 3))";
        printf '%s' "$BATTAPE_HISTORY_COLOR_RESET";
      else
        age="$((now - end))";
        if [ -z "$end" ] || [ "$age" -gt 86400 ]; then text_color="$BATTAPE_HISTORY_COLOR_OLDEST";
        elif [ "$age" -lt 3600 ]; then text_color="$BATTAPE_HISTORY_COLOR_RECENT";
        else text_color="$BATTAPE_HISTORY_COLOR_OLD";
        fi
        printf '  %s' "$text_color";
        __battape_truncate_display "$cmd" "$((cols - 3))";
        printf '%s' "$BATTAPE_HISTORY_COLOR_RESET";
      fi
    fi

    printf '\e[K';
    [ "$i" -lt $((rows - 1)) ] && printf '\r\n';
  done

  printf '\e8\e[u\e[%sC' "$((query_cursor_width + 2))"; # restore cursor to query
}

battape_render_history_ui() {
  __battape_initialize || return;

  local active_signal_traps cmd key now rows cols lines;
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
  [[ "$BATTAPE_HISTORY_MAX_ROWS" =~ ^[1-9][0-9]*$ ]] || BATTAPE_HISTORY_MAX_ROWS=12;
  rows="$((lines - 2))";
  [ "$rows" -gt "$BATTAPE_HISTORY_MAX_ROWS" ] && rows="$BATTAPE_HISTORY_MAX_ROWS";
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
  # Reserve the menu's rows before saving the cursor.  Using line feeds lets
  # the terminal scroll if necessary, without a cursor-position query whose
  # reply can leak into Readline on Bash 5.1.
  for ((i = 0; i < rows; i++)); do
    printf '\n';
  done
  printf '\e[%sA' "$rows";

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
  local command;

  command="$(fc -ln -1)";
  command="${command//\'/\'\'}";
  sqlite3 -cmd '.timeout 1000' "$BATTAPE_DB" <<HERE
insert into history (id, start, end, hostname, tty, pwd, command, exit_status) values (
  lower(hex(randomblob(10))),
  strftime('%s', 'now') - $(( SECONDS - LAST_INTERACTIVE_COMMAND_START )),
  strftime('%s', 'now'),
  '${HOSTNAME//\'/\'\'}',
  '$BATTAPE_CURRENT_TTY',
  '${PWD//\'/\'\'}',
  trim('$command', char(9, 10, 11, 12, 13, 32)),
  $1
)
HERE
  return "$1";
}

__battape_cd_osc7() {
  case "$BATTAPE_CD_OSC7" in
    never|0|no) return ;;
    auto) [ -t 1 ] && [ "${TERM:-dumb}" != dumb ] || return ;;
  esac
  printf '\e]7;file://%s%s\a' "$HOSTNAME" "$PWD";
}

__battape_cd_find() {
  local query="$1" q="%" term sql recency_days recency_seconds;
  local query_glob="${query//\'/\'\'}";
  local -a terms;

  recency_days="$BATTAPE_CD_RECENCY_DAYS";
  [[ "$recency_days" =~ ^[1-9][0-9]*$ ]] || recency_days=14;
  recency_seconds=$((recency_days * 86400));

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
      (strftime('%s', 'now') - max(end)) / ${recency_seconds}.0)) desc,
      max(end) desc
    limit 20";

  while IFS= read -r directory; do
    [ -d "$directory" ] && {
      printf '%s' "$directory";
      return;
    }
  done < <(sqlite3 -readonly -batch -cmd '.timeout 1000' -noheader "$BATTAPE_DB" "$sql" 2>/dev/null);
}

__battape_prompt_git() {
  local variable="$1" branch="" oid="" ahead=0 behind=0 color="" line;

  while IFS= read -r line; do
    case "$line" in
      '# branch.head '*) branch="${line#\# branch.head }" ;;
      '# branch.oid '*) oid="${line#\# branch.oid }" ;;
      '# branch.ab '*) read -r ahead behind <<< "${line#\# branch.ab }" ;;
      '# '*) ;;
      *) color="$BATTAPE_PROMPT_COLOR_RED" ;;
    esac
  done < <(git status --porcelain=v2 --branch 2>/dev/null);
  [ "$branch" = '(detached)' ] && branch="${oid:0:7}";
  [ -n "$branch" ] || {
    printf -v "$variable" '';
    return;
  }
  ahead="${ahead#+}";
  behind="${behind#-}";
  if [ "${ahead:-0}" -gt 0 ] || [ "${behind:-0}" -gt 0 ]; then
    printf -v "$variable" '%s%s (%s)' "$BATTAPE_PROMPT_COLOR_MAGENTA" "$color" "$branch";
  else
    printf -v "$variable" '%s (%s)' "$color" "$branch";
  fi
}

__battape_prompt_path() {
  local variable="$1" path="$PWD" relative depth="$BATTAPE_PROMPT_PATH_DEPTH" IFS=/;
  local -a parts;

  [[ "$depth" =~ ^[1-9][0-9]*$ ]] || depth=3;

  if [ "$path" = "$HOME" ]; then
    printf -v "$variable" '~';
    return;
  elif [[ "$path" == "$HOME"/* ]]; then
    relative="${path#"$HOME"/}";
    IFS=/ read -r -a parts < <(printf "%s" "$relative");
    if [ "${#parts[@]}" -gt "$depth" ]; then
      parts=("…" "${parts[@]: -depth}");
    fi
    printf -v "$variable" '~/%s' "${parts[*]}";
    return;
  fi

  [ "$path" = / ] && { printf -v "$variable" '/'; return; }
  IFS=/ read -r -a parts < <(printf "%s" "${path#/}");
  if [ "${#parts[@]}" -gt "$depth" ]; then
    parts=("…" "${parts[@]: -depth}");
  fi
  printf -v "$variable" '/%s' "${parts[*]}";
}

__battape_prompt_command() {
  local status="$1" elapsed=0 started="$LAST_INTERACTIVE_COMMAND_START" duration="" host="" git_prompt path_prompt;

  # Fix readdline bugs in Bash before 5.3 that can leave the terminal in raw, no-echo mode
  [ -z "$BATTAPE_TTY_FIX" ] || stty $BATTAPE_TTY_FIX;

  # battape normally installs itself through PROMPT_COMMAND.  Calling it here
  # keeps its history recording while leaving this prompt entirely native Bash.
  declare -F __battape_record >/dev/null && __battape_record "$status";

  # The DEBUG hook records the start of the command, whereas the previous
  # value here was set when the prior prompt was drawn (and therefore included
  # however long we sat idle at that prompt).
  started="${LAST_INTERACTIVE_COMMAND_START:-$started}";
  elapsed=$((SECONDS - started));
  [ "$elapsed" -ge 1 ] && duration=" ${elapsed}s";
  case "$BATTAPE_PROMPT_HOST" in
    always) host="${SHORTHOST:-$(hostname -s)} " ;;
    auto) [ -z "${SSH_CONNECTION:-}${SSH_TTY:-}" ] || host="${SHORTHOST:-$(hostname -s)} " ;;
  esac
  __battape_prompt_path path_prompt;
  [ "$BATTAPE_PROMPT_GIT" = 0 ] || __battape_prompt_git git_prompt;

  PS1="${BATTAPE_PROMPT_COLOR_BG}${BATTAPE_PROMPT_COLOR_HOST}${host}${BATTAPE_PROMPT_COLOR_FG}${path_prompt}${git_prompt}${BATTAPE_PROMPT_COLOR_FG}${duration} ";
  if [ "$status" -eq 0 ]; then
    PS1+="${BATTAPE_PROMPT_SUCCESS} ";
  else
    PS1+="${BATTAPE_PROMPT_COLOR_RED}${BATTAPE_PROMPT_FAILURE} ";
  fi
  PS1+="${BATTAPE_PROMPT_COLOR_BG_RESET}${BATTAPE_PROMPT_COLOR_SEPARATOR}${BATTAPE_PROMPT_SEPARATOR}${BATTAPE_PROMPT_COLOR_RESET} ";
  LAST_INTERACTIVE_COMMAND_START=$SECONDS;
}

__battape_requirements() {
  if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4))); then
    printf 'battape: Bash 4.4 or later is required\n' >&2;
    return 1;
  fi
  if ! command -v sqlite3 >/dev/null 2>&1; then
    printf 'battape: sqlite3 is required\n' >&2;
    return 1;
  fi
}

__battape_initialize() {
  [ -n "${__battape_initialized:-}" ] && return;
  __battape_requirements || return;

  mkdir -p "$(dirname "$BATTAPE_DB")" 2>/dev/null || :;
  sqlite3 -batch -cmd '.timeout 1000' "$BATTAPE_DB" <<'HERE' || return
create table if not exists history (
  id text primary key not null,
  start integer not null,
  end integer not null,
  hostname text not null,
  tty text not null,
  pwd text not null,
  command text not null,
  exit_status integer not null
);
create index if not exists idx_history_end on history(end);
create index if not exists idx_history_start on history(start);
create index if not exists idx_history_hostname on history(hostname);
create index if not exists idx_history_pwd on history(pwd);
HERE

  local schema_columns;
  schema_columns="$(sqlite3 -batch -noheader "$BATTAPE_DB" \
    "select group_concat(name, ',') from pragma_table_info('history') where name in ('id', 'start', 'end', 'hostname', 'tty', 'pwd', 'command', 'exit_status');")";
  if [[ "$schema_columns" != 'id,start,end,hostname,tty,pwd,command,exit_status' ]]; then
    printf 'battape: history table has an unsupported schema; command tracking disabled\n' >&2;
    return 1;
  fi

  BATTAPE_CURRENT_TTY="$(tty 2>/dev/null || echo '/dev/tty')";
  __battape_initialized=1;
}

battape_recorder_enable() {
  __battape_initialize || return;
  [ -n "${__battape_recorder_enabled:-}" ] && return;
  if [ -n "$(trap -p DEBUG)" ]; then
    printf 'battape: DEBUG trap already set; command tracking disabled\n' >&2;
    return 1;
  fi

  LAST_INTERACTIVE_COMMAND_START=$SECONDS;
  trap '[[ "$BASH_COMMAND" == __* ]] || LAST_INTERACTIVE_COMMAND_START="$SECONDS"' DEBUG;
  __battape_recorder_enabled=1;

  # The prompt renderer records directly when enabled, so do not add a second
  # recorder hook when it already owns PROMPT_COMMAND.
  [ -n "${__battape_prompt_enabled:-}" ] && return;
  if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == 'declare -a '* ]]; then
    PROMPT_COMMAND=("__battape_record \$?" "${PROMPT_COMMAND[@]}");
  else
    PROMPT_COMMAND="__battape_record \$?;${PROMPT_COMMAND%;}";
  fi
}
# A traced function inherits a caller's DEBUG trap. Without this attribute,
# Bash temporarily hides that trap while this function runs, making the guard
# above unable to protect it.
declare -ft battape_recorder_enable;

battape_prompt_enable() {
  battape_recorder_enable || return;

  # Keep escape sequences inside \[...\] so readline calculates the cursor
  # position correctly. The prompt function records the completed command.
  PROMPT_COMMAND='__battape_prompt_command "$?"';
  __battape_prompt_enabled=1;
}

battape_cd() {
  local directory;

  # Directory history is optional: preserve normal cd behaviour when battape
  # cannot be initialized (for example, without a supported Bash or SQLite).
  __battape_initialize || {
    builtin cd "$@";
    return;
  }

  # Let Bash handle a real path first. Suppressing its failure lets an absent
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
  builtin cd "$@" || return;
}
