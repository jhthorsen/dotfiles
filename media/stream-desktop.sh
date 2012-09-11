#!/bin/sh
# This script is used to capture the screen and save it to a file
# sudo apt-get install ffmpeg libavcodec-extra-53

FILE="$1"
INRES="1280x800"
OUTRES="1280x800"
FPS="20"

avconv -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -vcodec libx264 -s "$OUTRES" "$FILE"
