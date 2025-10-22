#!/bin/bash
[ -z "$SNAPSERVER" ] && exec echo "SNAPSERVER=example.com is not set" >&2;

SNAPCLIENT_BIN="$(find /opt/homebrew/Cellar/snapcast/*/bin/snapclient | sort | head -n1)";
[ -z "$SNAPCLIENT_BIN" ] && SNAPCLIENT_BIN="$(which snapclient)";
[ -z "$SNAPCLIENT_BIN" ] && exec echo "snapclient binary not found" >&2;

"$SNAPCLIENT_BIN" "$@" "tcp://127.0.0.1:1704" &
SNAPCLIENT_PID="$!";
trap "kill $SNAPCLIENT_PID; exit 0" EXIT SIGINT SIGTERM;
ssh -T -L 1704:127.0.0.1:1704 "$SNAPSERVER" "sleep 1d";
