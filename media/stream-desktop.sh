#!/bin/sh
# This script is used to capture the screen and save it to a file

#==============================
# Install deps
# sudo apt-get install ffmpeg libavcodec-extra-53

#==============================
# Install and start RTSP server
# cpanm -n --sudo RTSP::Server
# wget https://raw.github.com/revmischa/rtsp-server/master/rtsp-server.pl -O /usr/local/bin/rtsp-server.pl
# sudo chmod +x /usr/local/bin/rtsp-server.pl
# sudo rtsp-server.pl

#=============================
# Start capture
# ./media/stream-desktop.sh

#==============================
# Join capture
# mplayer rtsp://localhost/desktop

#==============================
# Example markup for flowplayer
# <!DOCTYPE>
# <html>
# <head>
#   <script src="/js/flowplayer.min.js"></script>
#   <script type="text/javascript">
#     window.onload = function() { flowplayer("player", "/flowplayer.swf") };
#   </script>
# </head>
# <body>
#   <a href="rtsp://localhost/desktop" id="player" style="display:block;width:800;height:600"></a>
# </body>
# </html>

INRES="1280x800"
OUTRES="1280x800"
FPS="20"

avconv \
    -f x11grab -s "$INRES" -r "$FPS" -i :0.0 -vcodec libx264 -s "$OUTRES" \
    -f rtsp -muxdelay 0.1 rtsp://localhost:5545/desktop
