#!/bin/sh
[ -r "$1" ] || exec echo "Usage: $0 input.mp4 input.mp3";
[ -r "$2" ] || exec echo "Usage: $0 input.mp4 input.mp3";

name="${1%.*}";
ext="${1##*.}";

ffmpeg -i "$1" -i "$2" -c:v copy -c:a aac -shortest "$name-merged.$ext";
