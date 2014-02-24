#!/bin/sh
#
# Purpose: This script will add xorg config files for Thinkpad X240 ClickPad (TouchPad) and Trackpoint.
# Usage:   bash thinkpad-x240-mouse.sh
# Author:  Jan Henning Thorsen
# Source:  https://github.com/jhthorsen/snippets/tree/master/etc/thinkpad-x240-mouse.sh
# TODO:    Add support for Trackpoint scrolling
#

XORG_CONFIG_DIR="/etc/X11/xorg.conf.d";
XORG_CONFIG_FILE="$XORG_CONFIG_DIR/20-thinkpad-x240.conf"

if [ "x$USER" != "xroot" ]; then
  sudo sh $0;
  exit $?;
fi

if ! [ -d $XORG_CONFIG_DIR ]; then
  mkdir $XORG_CONFIG_DIR;
fi

if [ -f $XORG_CONFIG_FILE ]; then
  echo "$XORG_CONFIG_FILE already exists. Skip install.";
  exit 0;
fi

cat <<"CONFIG" >> $XORG_CONFIG_FILE;
Section "InputClass"
    Identifier "touchpad"
    MatchProduct "SynPS/2 Synaptics TouchPad"
    Driver "synaptics"
    Option "SoftButtonAreas" "55% 0 0 20% 45% 55% 0 20%"
    Option "AreaTopEdge" "15%"
    Option "PalmDetect" "1"
    Option "HorizHysteresis" "24"
    Option "VertHysteresis" "24"
    #Option "AccelerationProfile" "1"
    #Option "AdaptiveDeceleration" "16"
    #Option "ConstantDeceleration" "16"
EndSection

Section "InputClass"
    Identifier "Trackpoint Wheel Emulation"
    MatchProduct "TPPS/2 IBM TrackPoint|DualPoint Stick|Synaptics Inc. Composite
    MatchDevicePath "/dev/input/event*"
    Driver "evdev"
    Option "Emulate3Buttons" "false"
    Option "EmulateWheel" "true"
    Option "EmulateWheelButton" "2"
    Option "EmulateWheelTimeout" "10"
    Option "XAxisMapping" "6 7"
    Option "YAxisMapping" "5 4"
EndSection
CONFIG

echo "Installed $XORG_CONFIG_FILE. Please restart xorg. (reboot)"

exit $?;
