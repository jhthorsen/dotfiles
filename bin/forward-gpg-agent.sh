#!/bin/bash
usage() {
  cat <<"HERE"

Examples:

  # Forward the gpg agent to ssh.example.org
  $ forward-gpg-agent.sh ssh.example.org;

  # Forward the gpg agent to ssh.example.org, but jump through another host first
  $ forward-gpg-agent.sh -J jumphost.example.org ssh.example.org;

  # Forward the gpg agent to ssh.example.org, but through two jump hosts and with a different usernames
  $ forward-gpg-agent.sh -o ProxyCommand="ssh u1@jump1.example.org ssh u2@jump2.example.org -W %h:%p" u3@ssh.example.org;

HERE

  exit 0
}

[ -z "$*" ] && usage;

set -e;
gpg -K;

set -x;
LOCAL_SOCKET="$(gpgconf --list-dirs agent-extra-socket)";
REMOTE_SOCKET="$(ssh -o ControlMaster=no "$@" gpgconf --list-dirs agent-socket)";

[ -z "$LOCAL_SOCKET" ] && exec echo "Can't find agent-extra-socket on $(hostname)" >/dev/stderr;
[ -z "$REMOTE_SOCKET" ] && exec echo "Can't find agent-socket on $1" >/dev/stderr;

ssh -o ControlMaster=no "$@" rm -f "$REMOTE_SOCKET" \
  && ssh -o ControlMaster=no -t -R "$REMOTE_SOCKET:$LOCAL_SOCKET" "$@" \
    /bin/sh -c "echo Hit enter to end session; read; sleep 1; rm $REMOTE_SOCKET";
