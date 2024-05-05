#!/bin/bash

make_dvd_from_file() {
  local video_file="$1";
  [ -z "$working_dir" ] && working_dir="$(mktemp -d -p "$PWD")";

  local mpg="$working_dir/dvd.mpg";
  local dvd_dir="$working_dir/dvd";
  local dvd_iso="$working_dir/dvd.iso";
  local video_filter="scale='if(gt(a,720/480),720,-1)':'if(gt(a,720/480),-1,480)',pad=w=720:h=480:x=(ow-iw)/2:y=(oh-ih)/2";

  [ -f "$mpg" ] || runx ffmpeg -i "$video_file" -filter:v "$video_filter" -aspect 16:9 -target ntsc-dvd "$mpg";

  export VIDEO_FORMAT="NTSC";
  [ ! -d "$dvd_dir" ] \
    && runx dvdauthor -t -o "$dvd_dir" -f "$mpg" \
    && runx dvdauthor -T -o "$dvd_dir";

  runx genisoimage -dvd-video -o "$dvd_iso" "$dvd_dir";
  echo "# next: growisofs -dvd-compat -Z /dev/sr0=$dvd_iso";
}

make_file_from_dvd() {
  local dvdrom="$1";
  local video_file="$2";
  [ -z "$preset" ] && preset="H.264 MKV 720p30";

  local type="$(exiftool -s3 -FileType "$dvdrom")";
  echo "$type" | grep -q "ISO\|DVD" || exec echo "Can't rip $dvdrom, since the type is ${type:-"Unknown"}." >/dev/stderr;

  if [ -z "$video_file" ]; then
    local date="$(exiftool -s3 -FileModifyDate "$dvdrom" | sed 's/[: ]/-/g')";
    [ -z "$date" ] && date="$(date +%F)";
    local name="$(exiftool -s3 -VolumeName "$dvdrom" | sed 's/[^a-zA-Z0-9]//g')";
    [ -z "$name" ] && name="dvd";
    local size="$(exiftool -s3 -FileSize "$dvdrom" | sed 's/[^0-9]//g')";
    [ -z "$size" ] && size="0";
    video_file="$name-$date-$size.mp4";
  fi

  [ -e "$video_file" ] && exec "Output file $video_file already exists!" >/dev/stderr

  # Using --preset instead of: --encoder x264 --x264-preset slow --x264-tune film --x264-profile main --two-pass --turbo --quality 23
  runx HandBrakeCLI --decomb --format mkv --markers --preset "$preset" \
    --input "$dvdrom" --output "$video_file" 2>&1 | grep -v "CHECK_VALUE";
}

runx() {
  echo "\$ $*";
  [ "$DRY_RUN" = "1" ] || "$@" || exit "$?";
}

main() {
  if [ -z "$1" ]; then
    echo "Usage: $0 [path/to/file.mp4|/dev/sr0]" >/dev/stderr;
  elif [ -f "$1" ]; then
    make_dvd_from_file "$@";
  elif [ -b "$1" ]; then
    make_file_from_dvd "$@";
  else
    echo "Can't handle $1." >/dev/stderr;
  fi
}

main "$@";
