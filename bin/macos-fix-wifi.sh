#!/bin/bash
set -e;

if [ "$1" = "install" ]; then
  set -x;
  PLIST="/Library/LaunchDaemons/com.meter.wifi.awdl.plist";
  SELF="$(realpath "$0")";
  DOT_FILES="$(dirname "$(dirname "$SELF")")";
  sudo cp "$DOT_FILES/config/macos/com.meter.wifi.awdl.plist" "$PLIST";
  sudo sed -i -- "s!FIX_AWDL_SCRIPT!$SELF!" "$PLIST";
  sudo launchctl unload -w "$PLIST";
  sudo launchctl load -w "$PLIST";
  exit;
fi

while :; do
  if /sbin/ifconfig awdl0 |grep -q "<UP"; then
    /sbin/ifconfig awdl0 down;
  fi

  sleep 1;
done
