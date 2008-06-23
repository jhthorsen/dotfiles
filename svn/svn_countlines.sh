#!/bin/sh

#==================
# svn_countlines.sh
#==================

REPO=$1;
REV_MIN=$2;
REV_MAX=$3;
OK='txt|css|js|sh|html|t|pl|pm|rc|cfg|conf';


if [ -z "$VERBOSE" ]; then
    VERBOSE=0;
fi


for rev in `seq ${REV_MIN} ${REV_MAX}`; do

    LINES=0;
    FILES=0;
    REPO_DATE=`svn info -r $rev $REPO | perl -ne'
                  /Last\sChanged\sDate:\s(.*)\s\(/
                  and print $1
                  and exit'`;

    if [ -z "$REPO_DATE" ]; then
        continue;
    fi

    LIST=`svn list -R -r$rev $REPO`;

    for f in $LIST; do
        FILES=$(( FILES += 1 ));
        echo $f | grep -iE "\.(${OK})$" >/dev/null || continue;
        L=`svn cat -r$rev $f 2>/dev/null | wc -l`;
        LINES=$(( LINES + L ));
    done

    echo "$rev - $REPO_DATE - $FILES - $LINES";

done

#===========================================
# sample output:
#
# 1 - 2006-04-05 22:25:03 +0200 - 109 - 5365
# 2 - 2006-04-05 23:00:45 +0200 - 109 - 5368
# 5 - 2006-04-08 18:18:14 +0200 - 109 - 5368
# 6 - 2006-04-08 18:20:55 +0200 - 113 - 6332
# 7 - 2006-04-08 18:21:50 +0200 - 113 - 6332
#
#===========================================

