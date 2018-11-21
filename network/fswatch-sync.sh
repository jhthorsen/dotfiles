#!/bin/sh
export REMOTE_HOST="$1";
export REMOTE_PATH="$2";
export PWD=$(realpath $PWD);

function _fswatch_sync_usage() {
  echo "Usage: $0 ssh.example.com /some/remote/path";
  exit 1;
}

[ -d "$PWD" ] \
  && [ -n "$REMOTE_PATH" ] \
  && ssh $REMOTE_HOST "ls $REMOTE_PATH 1>/dev/null" \
  || _fswatch_sync_usage;

echo "# Syncing $PWD => $REMOTE_HOST:$REMOTE_PATH ...";

fswatch \
  --latency=0.3 \
  --event-flag-separator=":" \
  -x \
  $PWD | perl -nE'
    BEGIN { $pwd_re = quotemeta $ENV{PWD} }
    chomp;
    $op = s/\s+(\S+)$// ? $1 : "Unknown";
    next unless $op =~ /IsFile/;
    $file = $_;
    s/^$pwd_re// or die "INVALID_FILE_NAME: $file ($pwd_re)";
    $rel = $_;
    @cmd = $op =~ /Removed/
      ? (ssh => -C => $ENV{REMOTE_HOST}, "rm $ENV{REMOTE_PATH}$rel")
      : (scp => -C => $file => "$ENV{REMOTE_HOST}:$ENV{REMOTE_PATH}$rel");
    say "> @cmd ($op)";
    system @cmd and exit $?';
