#!/bin/sh

#===========
# m4a2mp3.sh
#===========

MPLAYER="mplayer";
LAME="lame";
wav=`mktemp -u`;
mkfifo $wav || exit 255;

### convert
for f in *; do

    mp3=`echo "$f" | sed -e 's/\.\w*$/.mp3/'`;

    if [ "$mp3" != "$f" ]; then
        if [ ! -e "$mp3" ]; then
            echo $mp3;
            mplayer "$f" -ao pcm:file="$wav" &>/dev/null &
            lame "$wav" "$mp3";
        fi
    fi
done

rm $wav;
exit 0;
