#!/bin/sh

ssh_target_host="$1";
[ -z "$ssh_target_host" ] && exec echo "Usage: jump.sh <[local_port:]dest_host[:dest_port]> [cmd]" 1>/dev/stderr;
[ -z "$JUMP_TO_TARGET_FROM" ] && exec echo "JUMP_TO_TARGET_FROM= must be set" 1>/dev/stderr;

shift; # remove $dest from argument list
t="-T";
[ -z "$@" ] && t="-t";

if ! echo "$ssh_target_host" | grep -q ':'; then
  $JUMP_DRY_RUN ssh "$t" "$JUMP_TO_TARGET_FROM" ssh "$t" "$ssh_target_host" "$@";
  return "$?";
fi

# Ex: (3000 target.example.com 8080)
forward_args=(${ssh_target_host//:/ });
if [ "${#forward_args[@]}" = 2 ]; then
  forward_args=(${forward_args[1]}, "${forward_args[@]}");
fi

middle_port="$((${forward_args[0]} + 10000))";
localhost="127.0.0.1";
$JUMP_DRY_RUN ssh "$t" -L "$localhost:${forward_args[0]}:$localhost:$middle_port" "$JUMP_TO_TARGET_FROM" \
  ssh "$t" -L "$localhost:$middle_port:$localhost:${forward_args[2]}" "${forward_args[1]}" "$@";
