#!/bin/sh

dl() {
  wget "https://raw.githubusercontent.com/zsh-users/zsh-completions/master/src/$1" \
    -O "config/zsh/completion/$1";
}

dl _fail2ban-client;
dl _nftables;
dl _openssl;
dl _rfkill;
