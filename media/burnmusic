#!/bin/sh


### nothing to burn
if [ $# -le 0 ]; then
    echo "> No music to burn.";
    echo "> Example: $0 *.mp3";
    exit 255;
fi


### confirm
for song in "$@"; do
    echo " $song";
done

echo -e "Do you want to burn these files as audio? (y/N) ";
read answer;

if [ "x$answer" != "xy" ]; then
    exit 0;
fi


### burn mp3-files from the current folder
echo "Burnprogress started!";
for song in "$@"; do
	mpg123 --cdr - "$song" |                                   \
    cdrecord dev=/dev/hdc -v -audio -pad -nofix gracetime=2 -  \
    || exit $?;
done


### close disc
cdrecord -fix || exit $?;


### the end
exit 0;
