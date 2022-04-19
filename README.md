# jhthorsen's dotfiles and misc utilities

## Install dotfiles

    ./install.sh;

## Setup macos

    ./bin/macos-setup.sh;

## Featured scripts

### General tools

    ./bin/f                      # Simpler version of find
    ./bin/gof                    # pass <3 fzf
    ./bin/lorem                  # Takes a random man page and creates random text
    ./bin/ps                     # Get "ps f" in macos
    ./bin/snipclip               # Clipboard manager
    ./bin/vi                     # Wrapper around n((v)im)

### Git helpers

    ./bin/git-branch-summary     # Get a summary of all the branches
    ./bin/git-worklog            # Get a list of all the commits, including reflog

### MacOS tools

    ./bin/macos-dnsflush         # Flush the DNS cache in macos
    ./bin/macos-forward-port     # Forward a port in macos

### Tmux

    ./bin/tmux-shared            # Share a tmux session

### Fuse FS

    ./bin/fuse-filterfs          # Mount a directory with some invisible folders/files
    ./bin/fuse-unionfs           # Mount several directories as one
