#!/bin/bash
REMOTE_HOST="$1";

[ -z "$REMOTE_HOST" ] && exec echo "Usage: remote-gpg.sh <hostname>" >/dev/stderr;

set -e;
gpg -K;

LOCAL_SOCKET="$(gpgconf --list-dirs agent-extra-socket)";
REMOTE_SOCKET="$(ssh "$REMOTE_HOST" gpgconf --list-dirs agent-socket)";

[ -z "$LOCAL_SOCKET" ] && exec echo "Can't find agent-extra-socket on $(hostname)" >/dev/stderr;
[ -z "$REMOTE_SOCKET" ] && exec echo "Can't find agent-socket on $REMOTE_HOST" >/dev/stderr;

set -x;
ssh "$REMOTE_HOST" rm -f "$REMOTE_SOCKET" \
  && ssh -t -R "$REMOTE_SOCKET:$LOCAL_SOCKET" "$REMOTE_HOST" \
    /bin/sh -c "echo Hit enter to end session; read; sleep 1; rm $REMOTE_SOCKET";
