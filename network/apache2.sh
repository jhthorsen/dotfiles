#!/bin/sh

if [ "x$1" == "xshow_semaphore" ]; then
    ipcs -s | grep www-data;
fi

if [ "x$1" == "xrm_semaphore" ]; then
    ipcs -s          | \
    grep www-data    | \
    awk '{print $2}' | \
    xargs ipcrm sem;
fi

if [ "x$1" == "xshow_pid" ]; then
    fuser 80/tcp;
    fuser 443/tcp;
fi

if [ "x$1" == "xkill_pids" ]; then
    fuser 80/tcp;
    fuser 443/tcp;
fi

exit 0;

