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
