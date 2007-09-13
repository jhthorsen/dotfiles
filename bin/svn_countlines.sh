#!/bin/sh

#==============
# svncountlines
#==============

REPO=$1
REV_MIN=$2
REV_MAX=$3

if [ -z "$VERBOSE" ]; then
    VERBOSE=0
fi


for rev in `seq ${REV_MIN} ${REV_MAX}`; do

    TOTAL_LINES=0
    TOTAL_FILES=0
    REPO_DATE=`svn log -r $rev $REPO | grep -e'^r' | cut -d' ' -f 5,6`

    if [ -z "$REPO_DATE" ]; then
        continue
    fi

    for file in `svn list -R ${REPO}@${rev} | grep -ve'\/$'`; do

        LINES=`svn cat ${REPO}/${file}@${rev} | wc -l`
        TOTAL_LINES=`echo $(( $TOTAL_LINES + LINES ))`
        TOTAL_FILES=`echo $(( $TOTAL_FILES + 1 ))`

        if [ $VERBOSE = 1 ]; then
            echo "$file $LINES"
        fi

    done

    echo "$rev - $REPO_DATE - $TOTAL_FILES - $TOTAL_LINES"

done

#======================================
# sample output:
#
# 1 - 2006-04-05 22:25:03 - 109 - 5365
# 2 - 2006-04-05 23:00:45 - 109 - 5368
# 5 - 2006-04-08 18:18:14 - 109 - 5368
# 6 - 2006-04-08 18:20:55 - 113 - 6332
# 7 - 2006-04-08 18:21:50 - 113 - 6332
#
#======================================

