# Install from source

```
cd $HOME/git;
git clone -b master --depth 1 https://github.com/neovim/neovim.git;
cd neovim;
make CMAKE_BUILD_TYPE=RelWithDebInfo;
sudo make install;

cd $HOME/git;
mkdir lua-language-server;
curl -L https://github.com/LuaLS/lua-language-server/releases/download/3.6.19/lua-language-server-3.6.19-linux-arm64.tar.gz | tar xz -C $HOME/git/lua-language-server;
sudo ln -s $HOME/git/lua-language-server/bin/lua-language-server /usr/local/bin;
```

# Keys

https://hea-www.harvard.edu/~fine/Tech/vi.html

| **Key** | **Action**                                                         | **Followed by**                                                         | **^C**                                                        |
|---------|--------------------------------------------------------------------|-------------------------------------------------------------------------|---------------------------------------------------------------|
| a       | enter insertion mode after current character                       | text, ESC                                                               |                                                               |
| b       | back word                                                          |                                                                         |                                                               |
| c       | change command                                                     | cursor motion command                                                   |                                                               |
| d       | delete command                                                     | cursor motion command                                                   |                                                               |
| e       | end of word                                                        |                                                                         |                                                               |
| f       | find character after cursor in current line                        | character to find                                                       |                                                               |
| g       | UNBOUND                                                            |                                                                         |                                                               |
| h       | move left one character                                            |                                                                         |                                                               |
| i       | enter insertion mode before current character                      | text, ESC                                                               |                                                               |
| j       | move down one line                                                 |                                                                         |                                                               |
| k       | move up one line                                                   |                                                                         |                                                               |
| l       | move right one character                                           |                                                                         |                                                               |
| m       | mark current line and position                                     | mark character tag (a-z)                                                |                                                               |
| n       | repeat last search                                                 |                                                                         |                                                               |
| o       | open line below and enter insertion mode                           | text, ESC                                                               |                                                               |
| p       | put buffer after cursor                                            |                                                                         |                                                               |
| q       | UNBOUND                                                            |                                                                         |                                                               |
| r       | replace single character at cursor                                 | replacement character expected                                          |                                                               |
| s       | substitute single character with new text                          | text, ESC                                                               |                                                               |
| t       | same as f" but cursor moves to just before found character"        | character to find                                                       |                                                               |
| u       | undo                                                               |                                                                         |                                                               |
| v       | UNBOUND                                                            |                                                                         |                                                               |
| w       | move foreward one word                                             |                                                                         |                                                               |
| x       | delete single character                                            |                                                                         |                                                               |
| y       | yank command                                                       | cursor motion command                                                   |                                                               |
| z       | position current line                                              | CR = top; ." = center; "-"=bottom"                                      |                                                               |
| A       | enter insertion mode after end of line                             | text, ESC                                                               | UNBOUND                                                       |
| B       | move back one Word                                                 | back (up) one screen                                                    |                                                               |
| C       | change to end of line                                              | text, ESC                                                               | UNBOUND                                                       |
| D       | delete to end of line                                              | down half screen                                                        |                                                               |
| E       | move to end of Word                                                | scroll text up (cursor doesn't move unless it has to)                   |                                                               |
| F       | backwards version of f""                                           | character to find                                                       | foreward (down) one screen                                    |
| G       | goto line number prefixed, or goto end if none                     | show status                                                             |                                                               |
| H       | home cursor - goto first line on screen                            | backspace                                                               |                                                               |
| I       | enter insertion mode before first non-whitespace character         | text, ESC                                                               | (TAB) UNBOUND                                                 |
| J       | join current line with next line                                   | line down                                                               |                                                               |
| K       | UNBOUND                                                            | UNBOUND                                                                 |                                                               |
| L       | goto last line on screen                                           | refresh screen                                                          |                                                               |
| M       | goto middle line on screen                                         | (CR) move to first non-whitespace of next line                          |                                                               |
| N       | repeat last search, but in opposite direction of original search   | move down one line                                                      |                                                               |
| O       | open line above and enter insertion mode                           | text, ESC                                                               | UNBOUND                                                       |
| P       | put buffer before cursor                                           | move up one line                                                        |                                                               |
| Q       | leave visual mode (go into ex" mode)"                              | XON                                                                     |                                                               |
| R       | replace mode - replaces through end of current line, then inserts  | text, ESC                                                               | does nothing (variants: redraw; multiple-redo)                |
| S       | substitute entire line - deletes line, enters insertion mode       | text, ESC                                                               | XOFF                                                          |
| T       | backwards version of t""                                           | character to find                                                       | go to the file/code you were editing before the last tag jump |
| U       | restores line to state when cursor was moved into it               | up half screen                                                          |                                                               |
| V       | UNBOUND                                                            | UNBOUND                                                                 |                                                               |
| W       | foreward Word                                                      | UNBOUND                                                                 |                                                               |
| X       | delete backwards single character                                  | UNBOUND                                                                 |                                                               |
| Y       | yank entire line                                                   | scroll text down (cursor doesn't move unless it has to)                 |                                                               |
| Z       | first half of quick save-and-exit                                  | Z""                                                                     | suspend program                                               |
| 0       | move to column zero                                                |                                                                         |                                                               |
| 44570   | numeric precursor to other commands                                | [additional numbers (0-9)] command                                      |                                                               |
| SPACE   | (SPACE) move right one character                                   |                                                                         |                                                               |
| !       | shell command filter                                               | cursor motion command, shell command                                    |                                                               |
| @       | vi eval                                                            | buffer name (a-z)                                                       |                                                               |
| #       | UNBOUND                                                            |                                                                         |                                                               |
| $       | move to end of line                                                |                                                                         |                                                               |
| %       | match nearest [],(),{} on line, to its match (same line or others) |                                                                         |                                                               |
| ^       | move to first non-whitespace character of line                     | switch file buffers                                                     |                                                               |
| &       | repeat last ex substitution (:s ...") not including modifiers"     |                                                                         |                                                               |
| *       | UNBOUND                                                            |                                                                         |                                                               |
| (       | move to previous sentence                                          |                                                                         |                                                               |
| )       | move to next sentence                                              |                                                                         |                                                               |
| \       | UNBOUND                                                            | leave visual mode (go into ex" mode)"                                   |                                                               |
| |       | move to column zero                                                |                                                                         |                                                               |
| -       | move to first non-whitespace of previous line                      |                                                                         |                                                               |
| _       | similar to ^" but uses numeric prefix oddly"                       | UNBOUND                                                                 |                                                               |
| =       | UNBOUND                                                            |                                                                         |                                                               |
| +       | move to first non-whitespace of next line                          |                                                                         |                                                               |
| [       | move to previous {...}" section"                                   | (ESC) cancel started command; otherwise UNBOUND                         |                                                               |
| ]       | move to next {...}" section"                                       | use word at cursor to lookup function in tags file, edit that file/code |                                                               |
| {       | move to previous blank-line separated section                      |                                                                         |                                                               |
| }       | move to next blank-line separated section                          |                                                                         |                                                               |
| ;       | repeat last f"                                                     |                                                                         |                                                               |
| '       | move to marked line, first non-whitespace                          | character tag (a-z)                                                     |                                                               |
| `       | move to marked line, memorized column                              | character tag (a-z)                                                     |                                                               |
| :       | ex-submode                                                         | ex command                                                              |                                                               |
| "       | access numbered buffer; load or access lettered buffer             | 1-9,a-z                                                                 |                                                               |
| ~       | reverse case of current character and move cursor forward          |                                                                         |                                                               |
|         |                                                                    | reverse direction of last f"                                            |                                                               |
| .       | repeat last text-changing command                                  |                                                                         |                                                               |
| /       | search forward                                                     | search string, ESC or CR                                                |                                                               |
| <       | unindent command                                                   | cursor motion command                                                   |                                                               |
| >       | indent command                                                     | cursor motion command                                                   |                                                               |
| ?       | search backward                                                    | search string, ESC or CR                                                | (DELETE) UNBOUND                                              |

# Not used so much...

    va{  # select everything between "{"
    =ap  # Fix indentation inside a paragraph
    o    # Move to top/bottom of visiual selection
