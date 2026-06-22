#!/bin/bash

LOKI_URL="$LOKI_BASE_URL/loki/api/v1/push"
HOSTNAME="$(hostname)";

ps axu | awk 'NR>1 && $3 > 0.2 {print}' | while read -r line; do
  USER=$(echo "$line" | awk '{print $1}')
  CPU=$(echo "$line" | awk '{print $3}')
  PID=$(echo "$line" | awk '{print $2}')
  MEM=$(echo "$line" | awk '{print $4}')
  CMD=$(echo "$line" | awk '{for(i=11;i<=NF;++i)printf $i" "; print ""}')
  TS=$(date +%s%N)

  NAME="$(sed 's!^-!!' <<< "$CMD")";
  for _ in $(seq 1 200); do
    NAME="$(sed -E 's!([/a-z].*)[/ ].*!\1!' <<< "$NAME")";
    if [ -x "$NAME" ]; then
      NAME="$(basename "$NAME")";
      break;
    fi
  done
  NAME="$(sed 's! !-!g' <<< "$NAME")";

  LOG="{\"streams\": [{\"stream\": {\"hostname\": \"$HOSTNAME\", \"job\": \"ps\", \"user\": \"$USER\"}, \"values\": [[\"$TS\", \"cpu=$CPU mem=$MEM pid=$PID name=$NAME\"]]}]}"
  curl -X POST -H "Content-Type: application/json" --data "$LOG" "$LOKI_URL";
done
