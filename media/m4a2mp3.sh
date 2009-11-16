#!/bin/sh

#===========
# m4a2mp3.sh
#===========

MPLAYER="mplayer";
LAME="lame;


### convert
for m4a in *.m4a; do

    mp3=`echo "$m4a" | sed -e 's/m4a$/mp3/'`;
    wav="$m4a.wav";

    if [ ! -e "$mp3" ]; then
        [ -e "$wav" ] && rm "$wav";
        mkfifo "$wav" || exit 255;
        mplayer "$m4a" -ao pcm:file="$wav" &>/dev/null &
        lame "$wav" "$mp3";
        [ -e "$wav" ] && rm "$wav";
    fi
done

### the end
exit 0;
