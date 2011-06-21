#!/bin/sh

if [ -z $1 ]; then
    echo "usage: $0 <key>";
    exit;
fi

gpg --recv-keys $1;
gpg --export --armor $1 | sudo apt-key add -
