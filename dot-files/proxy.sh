[ -n "$HTTPS_PROXY" -a -z "$https_proxy" ] && export https_proxy="$HTTPS_PROXY";
[ -n "$HTTPS_PROXY" -a -z "$HTTP_PROXY"  ] && export HTTP_PROXY="$HTTPS_PROXY";
[ -n "$HTTP_PROXY"  -a -z "$http_proxy"  ] && export http_proxy="$HTTP_PROXY";
[ -n "$HTTP_PROXY"  -a -z "$FTP_PROXY"   ] && export FTP_PROXY="$HTTP_PROXY";
[ -n "$FTP_PROXY"   -a -z "$ftp_proxy"   ] && export ftp_proxy="$FTP_PROXY";
[ -n "$HTTP_PROXY"  -a -z "$NO_PROXY"    ] && export NO_PROXY="localhost,127.0.0.1"
[ -n "$NO_PROXY"    -a -z "$no_proxy"    ] && export no_proxy="$NO_PROXY";
