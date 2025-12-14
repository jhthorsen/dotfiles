#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Music Assistant Snapclient
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🎵

# Documentation:
# @raycast.description Music Assistant Snapclient
# @raycast.author Jan Henning Thorsen

abort() {
  echo "Err! $*";
  exit 1;
}

start_snapclient() {
  killall snapclient >/dev/null 2>&1 && sleep 1;
  find "$STATE_DIR/snapclient.log" -type f -size +1M -delete;
  "$SNAPCLIENT_BIN" --logsink=file:"$STATE_DIR/snapclient.log" "tcp://127.0.0.1:$SNAPCLIENT_PORT" &
  export SNAPCLIENT_PID=$!;
  echo "$SNAPCLIENT_PID" > "$STATE_DIR/snapclient.pid";
  return 0;
}

start_ssh() {
  ssh -S "$STATE_DIR/ssh.ctrl" -O check "$SNAPSERVER" && return 0;
  ssh -T -o ControlPersist=24h -o ControlMaster=auto -o ControlPath="$STATE_DIR/ssh.ctrl" "$SNAPSERVER" echo -n || return "$?";
  ssh -T -o ControlPath="$STATE_DIR/ssh.ctrl" -L "$SNAPCLIENT_PORT:127.0.0.1:$SNAPCLIENT_PORT" "$SNAPSERVER" echo -n || return $?;
  return 0;
}

eval "$(/opt/homebrew/bin/bash -c env)";
[ -r "$HOME/.config/music-assistant.sh" ] && source "$HOME/.config/music-assistant.sh";
[ -z "$SNAPSERVER" ] && abort "SNAPSERVER= must be set";

export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh";
export STATE_DIR="${STATE_DIR:-$HOME/.local/state/music-assistant-snapclient}";
export SNAPCLIENT_PORT="${SNAPCLIENT_PORT:-1704}";
export SNAPCLIENT_BIN="${SNAPCLIENT_BIN:-$(which snapclient)}";

[ -z "$SNAPCLIENT_BIN" ] && abort "snapclient binary not found";
[ -d "$STATE_DIR" ] || mkdir -p "$STATE_DIR";

start_ssh || abort "ssh: $?";
sleep 1;
start_snapclient || abort "snapclient: $?";
sleep 1;

ps -e | grep -q "snapclient.*tcp://127.0.0.1:$SNAPCLIENT_PORT" || abort "Not running!";
echo "Snapclient started";

exit 0;

Reason: Master running (pid=55158)
Err! snapclient: 1
Domain: scripts
Time: 05:25:03.429
