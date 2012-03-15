#!/bin/bash

WRAPPER_BIN="/usr/bin/spotify";
SPOTIFY_BIN="/usr/bin/spotify.bin";
SPOTIFY_DEB="http://download.spotify.com/preview/spotify-client_0.8.2.572.geb65f9a.433-1_amd64.deb";
SPOTIFY_PLUGIN_PATH="/opt/spotify/plugin";
FLASH_URL="http://download.macromedia.com/pub/labs/flashplayer10/flashplayer10_2_p3_64bit_linux_111710.tar.gz";
TMP="/tmp/spotify-installer.tmp";

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
        apt-get install libqt4-webkit;
        dpkg -i $TMP;
        mv $WRAPPER_BIN $SPOTIFY_BIN;
    fi
    echo Generating $WRAPPER_BIN ...;
    (cat <<CODE
#!/bin/sh
export MOZ_PLUGIN_PATH=$SPOTIFY_PLUGIN_PATH;
exec $SPOTIFY_BIN;
CODE
    ) > $WRAPPER_BIN;
    chmod +x $WRAPPER_BIN;

else
    if [ ! -e "$SPOTIFY_PLUGIN_PATH/libflashplayer.so" ]; then
        zenity --question --text "Do you want to install spotify with app support?" --title "Install spotify?" || exit $1;
        download $FLASH_URL;
        tar xfzv $TMP;
    fi
    [ -z "$SKIP_DOWNLOAD" ] && download $SPOTIFY_DEB;
    gksudo -k $0;
    zenity --info --text "Spotify was installed. It can be started from your application menu";
fi

exit $?;
