#!/bin/bash

WRAPPER_BIN="/usr/bin/spotify";
POOL="http://repository.spotify.com/pool/non-free/s/spotify/";
SPOTIFY_PLUGIN_PATH="/opt/spotify/plugin";
DOWNLOAD_DIR="/tmp";
FLASH_URL="http://download.macromedia.com/pub/labs/flashplayer10/flashplayer10_2_p3_64bit_linux_111710.tar.gz";
SKIP=$([ $(uname -p) = "x86_64" ] && echo "i386" || echo "amd64");
SELF="$(cd -P $(dirname $0); pwd)/$(basename $0)";

function download() {
    URL="$1";
    TARGET="/tmp/$2";
    TITLE=$(basename $URL);

    echo "wget $URL";
    wget $URL -O $TARGET 2>&1 \
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
        dpkg -i $DOWNLOAD_DIR/spotify*deb;
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

else # $USER is not "root"
    zenity --question --text "Do you want to install spotify with app support?" --title "Install spotify?" || exit $1;
    if [ ! -e "$SPOTIFY_PLUGIN_PATH/libflashplayer.so" ]; then
        download $FLASH_URL $(basename $FLASH_URL);
        tar xfzv $DOWNLOAD_DIR/$(basename $FLASH_URL);
    fi
    if [ -z "$SKIP_DOWNLOAD" ]; then
        PACKAGES=0;
        for p in $(wget -q $POOL -O - | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2 | uniq); do
            PACKAGES=$((PACKAGES+1));
            [ "x$VERBOSE" != "x" ] && echo "Found package $p in deb pool";
            echo $p | grep "^spotify" >/dev/null || continue;
            [ -e "$p" ] && continue;
            echo $p | grep $SKIP > /dev/null || download "$POOL/$p" $p;
        done
        if [ "x$PACKAGES" = "x0" ]; then
            zenity --info --text "Could not get package list from $POOL";
        fi
    fi

    gksudo -k $SELF;
    zenity --info --text "Spotify was installed. It can be started from your application menu";
fi

exit $?;
