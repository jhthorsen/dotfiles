# tmux requires unrecognized OSC sequences to be wrapped with DCS tmux;
# <sequence> ST, and for all ESCs in <sequence> to be replaced with ESC ESC. It
# only accepts ESC backslash for ST.
function print_osc() {
  if [[ $TERM == screen* ]]; then
    printf "\033Ptmux;\033\033]"
  else
    printf "\033]"
  fi
}

# More of the tmux workaround described above.
function print_st() {
  if [[ $TERM == screen* ]]; then
    printf "\a\033\\"
  else
    printf "\a"
  fi
}

function setkeylabel_show_help() {
  echo "Usage:" 1>& 2
  echo "  setkeylabel set Fn Label" 1>& 2
  echo "     Where n is a value from 1 to 20" 1>& 2
  echo "  setkeylabel push [name]" 1>& 2
  echo "    Saves the current labels with an optional name. Resets labels to their default value, unless name begins with a "." character." 1>& 2
  echo "  setkeylabel pop [name]" 1>& 2
  echo "    If name is given, all key labels up to and including the one with the matching name are popped." 1>& 2
  echo "" 1>& 2
  echo "Example:" 1>& 2
  echo "#!/bin/bash" 1>& 2
  echo "# Wrapper script for mc that sets function key labels" 1>& 2
  echo "NAME=mc_\$RANDOM" 1>& 2
  echo "# Save existing labels" 1>& 2
  echo "setkeylabel push \$NAME" 1>& 2
  echo "setkeylabel set F1 Help" 1>& 2
  echo "setkeylabel set F2 Menu" 1>& 2
  echo "setkeylabel set F3 View" 1>& 2
  echo "setkeylabel set F4 Edit" 1>& 2
  echo "setkeylabel set F5 Copy" 1>& 2
  echo "setkeylabel set F6 Move" 1>& 2
  echo "setkeylabel set F7 Mkdir" 1>& 2
  echo "setkeylabel set F8 Del" 1>& 2
  echo "setkeylabel set F9 Menu" 1>& 2
  echo "setkeylabel set F10 Quit" 1>& 2
  echo "setkeylabel set F11 Menu" 1>& 2
  echo "setkeylabel set F13 View" 1>& 2
  echo "setkeylabel set F14 Edit" 1>& 2
  echo "setkeylabel set F15 Copy" 1>& 2
  echo "setkeylabel set F16 Move" 1>& 2
  echo "setkeylabel set F17 Find" 1>& 2
  echo "mc" 1>& 2
  echo "# Restore labels to their previous state" 1>& 2
  echo "setkeylabel pop \$NAME" 1>& 2
}

setkeylabel () {
  if [[ $1 == set ]]; then
    if [[ $# != 3 ]]; then
      setkeylabel_show_help
    else
      print_osc
      printf "1337;SetKeyLabel=%s=%s" "$2" "$3"
      print_st
    fi
  elif [[ $1 == push ]]; then
    if [[ $# == 1 ]]; then
      print_osc
      printf "1337;PushKeyLabels"
      print_st
    elif [[ $# == 2 ]]; then
      if [[ $2 == "" ]]; then
        echo "Name must not be empty" 1>& 2
      fi
      print_osc
      printf "1337;PushKeyLabels=%s" "$2"
      print_st
    fi
  elif [[ $1 == pop ]]; then
    if [[ $# == 1 ]]; then
      print_osc
      printf "1337;PopKeyLabels"
      print_st
    elif [[ $# == 2 ]]; then
      if [[ $2 == "" ]]; then
        echo "Name must not be empty" 1>& 2
      fi
      print_osc
      printf "1337;PopKeyLabels=%s" "$2"
      print_st
    fi
  elif [[ $1 == help ]]; then
    setkeylabel_show_help
  fi
}
