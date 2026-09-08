# jhthorsen's dotfiles and utilities

Personal configuration for macOS and a collection of small command-line tools. The shell configuration puts this repository's `bin/` directory on `PATH`, so its scripts are available by name in a new shell.

## Installation

Clone the repository, then run the installer:

    ./install.sh

The installer generates the Bash startup files and links the included configuration for Bash, Neovim, tmux, Git, Ghostty, WezTerm, and other tools. It also contains optional Homebrew, CPAN, and macOS setup routines. Review `install.sh` before running it: this is a personal setup and it may install software or expect machine-specific files.

## Included commands

`bin/` contains standalone scripts intended for interactive use and shell pipelines. Most dependencies are deliberately not bundled; install the underlying command when a script needs it (for example, `git`, `fzf`, `nmap`, `pandoc`, ImageMagick, or `sqlite3`).

### Everyday tools

    gof                      # Fuzzy-find files with fzf
    lorem                    # Generate filler text from a random man page
    ps                       # Display a process tree on macOS
    snipclip                 # Manage clipboard snippets
    clean                    # Clear the terminal, optionally including scrollback
    gensecret [length]       # Generate a random, URL-safe-ish secret
    md <file>                # Render Markdown as terminal-friendly text
    wctime <file> [speed]    # Estimate reading time for a file

### Text, data, and files

    boxify                   # Convert ASCII table borders to Unicode (use -r to reverse)
    diffu                    # Page diffs, using bat when appropriate
    tablify                  # Arrange whitespace- or tab-separated input into columns
    to_json                  # Parse relaxed JSON and print canonical, pretty JSON
    tzlog <offset>           # Convert timestamps in a log stream to another time zone
    filetk                   # File helpers: duplicate detection, EXIF renaming, photo export
    b64img [convert args]    # Convert an image to PNG and write Base64 to stdout

### Git and networking

    git-branch-summary       # Summarize local branches
    git-worklog              # List commits, including reflog history
    git-update-all           # Update Git repositories
    git-push.sh              # Push a repository with the configured workflow
    nmap-table [nmap args]   # Run nmap with grep-friendly output
    check-domain-names.sh    # Check candidate domain names read from stdin
    jump.sh target [command] # Run a command through an SSH jump host

### Time tracking with battape

`tt` is a local, SQLite-backed time tracker. It records entries in `${XDG_DATA_HOME:-~/.local/share}/battape/battape.sqlite` by default and supports starting, stopping, editing, reporting, syncing, and associating commands with entries.

    tt start -a client -d "Implement feature" -t "work,feature"
    tt stop
    tt report --group day
    tt --help

For the background and implementation details, see [Rewrite it in Bash](https://thorsenlabs.com/blog/2026-09-07-rewrite-it-in-bash), which discusses `battape.sh`.

### macOS-specific commands

    macosctl                 # Apply or inspect macOS preferences
    macos-restart-app <app>  # Restart an application
    macos-cpanm-helper       # Helper for macOS Perl/CPAN setup

## macOS manual setup

Some applications still need to be installed manually:

- [BetterTouchTool](https://folivora.ai/)
- [FUJIFILM X RAW STUDIO](https://fujifilm-x.com/en-us/support/download/software/x-raw-studio/)
- [Spotify](https://open.spotify.com/)
- [Coinverter](https://apps.apple.com/no/app/coinverter/id926121450?mt=12)
- [Commander One](https://apps.apple.com/no/app/commander-one-file-manager/id1035236694?mt=12)
- [Peek](https://apps.apple.com/no/app/peek-a-quick-look-extension/id1554235898?mt=12)
- [Pixelmator Pro](https://apps.apple.com/no/app/pixelmator-pro/id1289583905?mt=12)

Set the computer name as needed:

    sudo scutil --set HostName "$hostname"

## Keyboards

### Default

    1 2 3 4 5 6 7 8 9 0 - ^ ¥
     q w e r t y u i o p @ [
     a s d f g h j k l ; : ]
      z x c v b n m , . / _

    ! " # $ % & ' ( ) 0 = ~ |
     Q W E R T Y U I O P ` {
     A S D F G H J K L + * }
      Z X C V B N M < > ? _

### ABC Programming

    1 2 3 4 5 6 7 8 9 0 - ^ Â ¥
     q w e r t y u i o p [ ]
     a s d f g h j k l ; : @
      z x c v b n m , . / \

    ! " # $ % & ' ( ) = _ ~ |
     Q W E R T Y U I O P { }
     A S D F G H J K L + * |
      Z X C V B N M < > ? _

### ABC Programming + BetterTouchTool

    _ _ _ _ _ _ / _ _ _ _ _ _
     _ _ _ _ _ _ _ _ _ _ å _
     _ _ _ _ _ _ _ _ _ ø æ _
      _ _ _ _ _ _ _ _ _ _ _

    _ _ _ _ _ _ _ _ _ _ _ _ _
     _ _ _ _ _ _ _ _ _ _ ` _
     _ _ _ _ _ _ _ _ _ _ _ _
      _ _ _ _ _ _ _ _ _ _ _

## Resources

- [Everything you need to know to configure Neovim using Lua](https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/)
