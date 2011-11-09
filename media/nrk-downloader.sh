#!/bin/sh

man() {
    cat <<'MAN'
NAME
    nrk-downloader.sh - Download streams from nrk.no - version 0.03

SYNOPSIS
    Help:
    $ nrk-downloader.sh

    Download a single episode:
    $ nrk-downloader.sh http://www1.nrk.no/nett-tv/klipp/582810

    Download a complete show:
    $ nrk-downloader.sh http://www1.nrk.no/nett-tv/kategori/3521

    The number at the end of the url can be copy/pasted from the
    location bar in your browser, after locating the show.

DESCRIPTION
    This script use vlc to download streams from
    http://www1.nrk.no/nett-tv/.

REQUIREMENTS
    Basic command line tools, vlc, wget and perl

AUTHOR
    Written by Jan Henning Thorsen - jhthorsen [at] cpan.org
MAN
}

HREF=$1;
COOKIE='Cookie: NetTV2.0Speed=NetTV2.0Speed=10000';

VCODEC=${VCODEC-mp4v}
VBITRATE=${VBITRATE-1024}
ACODEC=${ACODEC-mp3}
ARATE=${ARATE-128}
ACHANNELS=${ACHANNELS-2}
MUX=${MUX-asf}

download () {
    param_value=$(
        wget --header "$COOKIE" "$1" -q -O- \
        | grep -i "Filename" \
        | cut -d\" -f4 \
    );

    mms_file=$(
        wget "$param_value" -O - -q \
        | grep "ref href" \
        | cut -d\" -f2 \
        | head -n 1 \
    );

    out_file=$(basename $mms_file);

    if [ -e $out_file ]; then
        echo "# Will skip $out_file: Already exists.";
        return 0;
    fi

    echo "# Streaming $mms_file";

    if [ -z $TRANSCODE ]; then
        cvlc $mms_file vlc://quit \
            --sout file/avi:$out_file \
            --quiet -I dummy &
    else
        cvlc $mms_file vlc://quit \
            --sout "#transcode{vcodec=$VCODEC,vb=$VBITRATE,acodec=$ACODEC,ab=$ARATE,channels=$ACHANNELS}:standard{mux=$MUX,dst='$out_file',access=file}"
            --quiet -I dummy &
    fi

    VLC_PID=$!

    while kill -0 $VLC_PID; do
        sleep 2;
        SIZE=$(du -h $out_file);
        printf "# Written $SIZE       \r";
    done

    return $?;
}

if echo $HREF | grep -q '/klipp/'; then
    download $HREF;
    exit $?;
elif echo $HREF | grep -q '/\(kategori\|prosjekt\)/'; then
    LINKS=$(
        wget --header "$COOKIE" "$HREF" -q -O- \
        | perl -nle'print for m,href="(/nett-tv/klipp[^"]+),g' \
        | sort -u \
    );

    for href in $LINKS; do
        echo "# Fetching http://www1.nrk.no$href";
        download "http://www1.nrk.no$href";
    done

    exit 0;
else 
    man;
    exit 1;
fi
