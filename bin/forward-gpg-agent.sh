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

logf() {
  local where="$1"; shift;
  local action="$1"; shift;
  echo "[$where] action=$action local_socket=\"$LOCAL_SOCKET\" remote_socket=\"$REMOTE_SOCKET\" $*" >/dev/stderr;
  return 0;
}

sshx() {
  ssh -xT -o ControlMaster=no "$@" || exit "$?";
}

LOCAL_SOCKET="$(gpgconf --list-dirs agent-extra-socket)";
[ -z "$LOCAL_SOCKET" ] && logf localhost discover-agent-extra-socket "gpgconf --list-dirs agent-extra-socket failed" && exit 1;

if [ -z "$REMOTE_SOCKET" ]; then
  logf remotehost discover-agent-socket;
  REMOTE_SOCKET="$(sshx "$@" 's="$(gpgconf --list-dirs agent-socket)";rm "$s" 2>/dev/null;echo "$s"')";
else
  logf remotehost cleanup-agent-socket;
  sshx "$@" "rm '$REMOTE_SOCKET'";
fi

[ -z "$LOCAL_SOCKET" ] && logf remotehost discover-agent-socket "gpgconf --list-dirs agent-socket failed" && exit 1;

logf remotehost forward-agent-extra-socket;
sshx -R "$REMOTE_SOCKET:$LOCAL_SOCKET" "$@" 'while echo "[$(date --iso-8601=seconds)] connected_to=$(hostname)";do sleep 600;done';
