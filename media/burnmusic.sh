#!/bin/sh

if [ $# -le 0 ]; then
    echo "Usage: $0 *.mp3";
    exit 255;
fi

for song in "$@"; do
    echo " $song";
done

echo -e "Do you want to burn these files as audio? (y/N) ";
read answer;

if [ "x$answer" != "xy" ]; then
    exit 0;
fi

echo "Burnprogress started. Please wait...";

for song in "$@"; do
    mpg123 --cdr - "$song" \
        | cdrecord dev=/dev/hdc -v -audio -pad -nofix gracetime=2 - \
        || exit $?;
done

# close disc
cdrecord -fix || exit $?;

exit 0;
