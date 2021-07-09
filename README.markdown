# Batman's toolbelt

## GPG

```
gpg --list-secret-keys;
gpg --export-secret-key XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX \
  | ssh -t remote.host.local 'cat > to-import.gpg; chmod +x to-import.gpg';

ssh remote.host.local;
echo "pinentry-program /usr/bin/pinentry-curses" >> $HOME/.gnupg/gpg-agent.conf;
export GPG_TTY=$(tty);
gpg --import to-import.gpg && rm to-import.gpg;
```

## Netdata

```
xcode-select --install
brew install ossp-uuid autoconf automake pkg-config libuv lz4 json-c openssl@1.1 libtool cmake
git clone https://github.com/netdata/netdata.git --recursive
cd netdata/
sudo ./netdata-installer.sh --install /usr/local --stable-channel --disable-backend-mongodb --disable-telemetry
```
