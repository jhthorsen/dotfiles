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

### MacOS manual steps

- https://folivora.ai/
- https://fujifilm-x.com/en-us/support/download/software/x-raw-studio/
- https://open.spotify.com/
- https://apps.apple.com/no/app/coinverter/id926121450?mt=12
- https://apps.apple.com/no/app/commander-one-file-manager/id1035236694?mt=12
- https://apps.apple.com/no/app/peek-a-quick-look-extension/id1554235898?mt=12
- https://apps.apple.com/no/app/pixelmator-pro/id1289583905?mt=12

    sudo scutil --set HostName $hostname;

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

* [Everything you need to know to configure neovim using lua](https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/)
