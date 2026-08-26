__dotfiles_prompt_path() {
  local path="$PWD" relative part output="";
  local -a parts;

  if [ "$path" = "$HOME" ]; then
    printf '~';
    return;
  elif [[ "$path" == "$HOME"/* ]]; then
    relative="${path#"$HOME"/}";
    IFS=/ read -r -a parts <<< "$relative";
    if [ "${#parts[@]}" -gt 3 ]; then
      parts=("…" "${parts[@]: -3}");
    fi
    printf '~/%s' "$(IFS=/; printf '%s' "${parts[*]}")";
    return;
  fi

  [ "$path" = / ] && { printf '/'; return; }
  IFS=/ read -r -a parts <<< "${path#/}";
  if [ "${#parts[@]}" -gt 3 ]; then
    parts=("…" "${parts[@]: -3}");
  fi
  printf '/%s' "$(IFS=/; printf '%s' "${parts[*]}")";
}

__dotfiles_prompt_git() {
  local branch state ahead behind counts color="";

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return;
  branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)";
  [ -n "$branch" ] || return;

  state="$(git status --porcelain 2>/dev/null)";
  if [ -n "$state" ]; then
    color="$DOTFILES_PROMPT_RED";
  fi

  if counts="$(git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)"; then
    read -r behind ahead <<< "$counts";
  fi
  if [ "${ahead:-0}" -gt 0 ] || [ "${behind:-0}" -gt 0 ]; then
    printf '%s' "$DOTFILES_PROMPT_MAGENTA";
  fi
  printf '%s (%s)' "$color" "$branch";
}

__dotfiles_prompt_command() {
  local status="$1" elapsed=0 started="$LAST_INTERACTIVE_COMMAND_START" duration="" host="" git_prompt;

  # battape normally installs itself through PROMPT_COMMAND.  Calling it here
  # keeps its history recording while leaving this prompt entirely native Bash.
  declare -F __battape_record >/dev/null && __battape_record "$status";

  # battape's DEBUG hook records the start of the command, whereas the
  # previous value here was set when the prior prompt was drawn (and therefore
  # included however long we sat idle at that prompt).
  [ -n "${__battape_loaded:-}" ] && started="${LAST_INTERACTIVE_COMMAND_START:-$started}";
  elapsed=$((SECONDS - started));
  [ "$elapsed" -ge 1 ] && duration=" ${elapsed}s";
  [ "$SHORTHOST" = "macbat2" ] || host="${SHORTHOST} ";
  git_prompt="$(__dotfiles_prompt_git)";

  PS1="${DOTFILES_PROMPT_BG}${DOTFILES_PROMPT_FG}${host}$(__dotfiles_prompt_path)${git_prompt}${DOTFILES_PROMPT_FG}${duration} ";
  if [ "$status" -eq 0 ]; then
    PS1+="✓ ";
  else
    PS1+="${DOTFILES_PROMPT_RED}✗ ";
  fi
  PS1+="${DOTFILES_PROMPT_BG_RESET}${DOTFILES_PROMPT_POWERLINE}${DOTFILES_PROMPT_RESET} ";
  LAST_INTERACTIVE_COMMAND_START=$SECONDS;
}

# Keep escape sequences inside \[...\] so readline calculates the cursor
# position correctly.  The colours match the previous prompt theme.
DOTFILES_PROMPT_BG='\[\e[48;2;48;48;48m\]';
DOTFILES_PROMPT_BG_RESET='\[\e[49m\]';
DOTFILES_PROMPT_MAGENTA='\[\e[35m\]';
DOTFILES_PROMPT_POWERLINE='\[\e[38;2;48;48;48m\]';
DOTFILES_PROMPT_RED='\[\e[31m\]';
DOTFILES_PROMPT_RESET='\[\e[0m\]';
[ "$SHORTHOST" = "macbat2" ] \
  && DOTFILES_PROMPT_FG='\[\e[38;2;2;175;215m\]' \
  || DOTFILES_PROMPT_FG='\[\e[38;2;221;130;20m\]';
PROMPT_COMMAND='__dotfiles_prompt_command "$?"';
