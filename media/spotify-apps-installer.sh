#!/bin/bash

WRAPPER_BIN="/usr/bin/spotify";
SPOTIFY_DEB="http://download.spotify.com/preview/spotify-client_0.8.2.572.geb65f9a.433-1_amd64.deb";
SPOTIFY_PLUGIN_PATH="/opt/spotify/plugin";
FLASH_URL="http://download.macromedia.com/pub/labs/flashplayer10/flashplayer10_2_p3_64bit_linux_111710.tar.gz";
TMP="/tmp/spotify-installer.tmp";
SELF="$(cd -P $(dirname $0); pwd)/$(basename $0)";

function download() {
    URL=$1;
    TITLE=$(basename $URL);

    echo "wget $URL";
    wget $URL -O $TMP 2>&1 \
        | sed -u 's/.*\ \([0-9]\+%\)\ \+\([0-9.]\+\ [KMB\/s]\+\)$/\1\n# Downloading \2/' \
        | zenity --progress --text="Downloading $TITLE" --title="Downloading $TITLE ..." --auto-close --auto-kill

    return $?
}

if [ "$USER" == "root" ]; then
    if [ ! -e "$SPOTIFY_PLUGIN_PATH/libflashplayer.so" ]; then
        mkdir -p $SPOTIFY_PLUGIN_PATH;
        mv libflashplayer.so $SPOTIFY_PLUGIN_PATH;
    fi
    if [ -z "$SKIP_DOWNLOAD" ]; then
        apt-get install libqt4-webkit libssl0.9.8;
        dpkg -i $TMP;
    fi

    TYPE=$(file -b --mime-type $WRAPPER_BIN);
    if [ "x$TYPE" != "xtext/x-shellscript" ]; then
        echo "Moving binary away...";
        mv $WRAPPER_BIN $WRAPPER_BIN.bin;
    fi

    echo Generating $WRAPPER_BIN ...;
    (cat <<CODE
#!/bin/sh
export MOZ_PLUGIN_PATH=$SPOTIFY_PLUGIN_PATH;
exec $WRAPPER_BIN.bin;
CODE
    ) > $WRAPPER_BIN;
    chmod +x $WRAPPER_BIN;

else
    zenity --question --text "Do you want to install spotify with app support?" --title "Install spotify?" || exit $1;
    if [ ! -e "$SPOTIFY_PLUGIN_PATH/libflashplayer.so" ]; then
        download $FLASH_URL;
        tar xfzv $TMP;
    fi
    [ -z "$SKIP_DOWNLOAD" ] && download $SPOTIFY_DEB;
    gksudo -k $SELF;
    zenity --info --text "Spotify was installed. It can be started from your application menu";
fi

exit $?;
