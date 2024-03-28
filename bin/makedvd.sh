#!/bin/bash

runx() {
  echo "\$ $*";
  "$@" || exit "$?";
}

in="$1";
[ -z "$in" ] && exec echo "Usage: $0 file.mp4";
[ -z "$wdir" ] && wdir="$(mktemp -d -p "$PWD")";

mpg="$wdir/dvd.mpg";
dvd_dir="$wdir/dvd";
dvd_iso="$wdir/dvd.iso";
video_filter="scale='if(gt(a,720/480),720,-1)':'if(gt(a,720/480),-1,480)',pad=w=720:h=480:x=(ow-iw)/2:y=(oh-ih)/2";

[ -f "$mpg" ] || runx ffmpeg -i "$in" -filter:v "$video_filter" -aspect 16:9 -target ntsc-dvd "$mpg";

export VIDEO_FORMAT="NTSC";
[ ! -d "$dvd_dir" ] \
  && runx dvdauthor -t -o "$dvd_dir" -f "$mpg" \
  && runx dvdauthor -T -o "$dvd_dir";

runx genisoimage -dvd-video -o "$dvd_iso" "$dvd_dir";
echo "# next: growisofs -dvd-compat -Z /dev/sr0=$dvd_iso";
