#!/bin/sh

#== HELP =====================================================================
#    backup.sh - a backup script! :D                               Version 0.9
#    Written by jhThorsen - http://flodhest.net/
# 
# *) This script use `rsync` to make backup from one host to another, and in
#    addition it creates incremental backups, using hard links. (This means
#    that the script cannot backup hard links)
# 
#    The backup is stored in this path: $DST_DIR/$BACKUP_NAME/ on $DST_HOST.
#    ./incoming          = temporary directory where rsync puts it's data.
#    ./<interval>.<date> = directory that holds a backup.
#                          <date> = [month][dayofmonth]-[hour][minute]
#                          Number of backups are controlled by $KEEP_HOUR and
#                          $KEEP_DAY.
# 
# *) General usage: `backup.sh <interval> <config-file>`.
#    <interval> can be 'hour' or 'day'.
#    Config-file settings can be found later in the source. (look for
#    "CONFIG FILE SAMPLE").
# 
# *) The backup-script must be initialized from the computer that is taken
#    backup from.
# 
# *) The backup-script must be in $PATH on both computers.
# 
# *) If you want to do automated backups, you would have to install
#    ssh-certificates: `backup.sh keygen <config-file>` (This is done from
#    the computer that is taken backup from)
#    In addition you can add something like this to your crontab:
#    30 */4 *   * * /usr/local/sbin/backup.sh backup hour backup.conf
#    0  2   */1 * * /usr/local/sbin/backup.sh backup day backup.conf
# 
# *) The script relies on `ssh` and `rsync` + generic commandline tools...
# 
#=============================================================================


### CONFIG FILE SAMPLE START
BACKUP_NAME="";      # the name of the backup
SRC_DIR="";          # where to take backup from
DST_HOST="";         # destination host (can be user@host)
DST_DIR="";          # $DST_DIR must exist on $DST_HOST
RSYNC_USER_ARGS="";  # ex: '--include foo --exclude bah'
KEEP_HOUR=0;         # how many hourly backups to backtrack
KEEP_DAY=0;          # how many daily backups to backtrack
RUN_BEFORE="";       # program to run, before every backup
RUN_AFTER="";        # program to run, after every backup
MAILTO="";           # email adress to post report to
### CONFIG FILE SAMPLE END


### INIT
PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin";
ACTION=$1;
RSYNC_ARGS="-az --relative --delete-after --numeric-ids";
LOG_DIR="/var/log/backup.sh";


### USAGE
if [ "$ACTION" != "test"    ]        \
&& [ "$ACTION" != "hour"    ]        \
&& [ "$ACTION" != "day"     ]        \
&& [ "$ACTION" != "keygen"  ]        \
&& [ "$ACTION" != "cleanup" ]; then
    grep -e '^#[ =]' $0 | sed 's/[#=]/ /g';
    exit 0;
fi


mail_report() { #=============================================================

    [ -z "$MAILTO" ] && return 254;

    VALUE="$1";
    MESSAGE="$2";
    TIMESTAMP=`date +%m%d-%H%M`;

    ### SEND MAIL
    {
        echo "From: backup.sh@${HOSTNAME}";
        echo "To: $MAILTO";
        echo "Subject: Backed up $BACKUP_NAME ($VALUE)";
        echo "Content-type: text/plain";
        echo;
        echo "$MESSAGE";
    } | sendmail -t;

    ### THE END
    return $?;
}

read_config() { #=============================================================

    if [ -f "$1" ]; then
        . "$1";
    else
        echo "-!- Not a config-file: $CONFIG_FILE";
        exit 200;
    fi

}

check_backup_name() { #=======================================================

    if echo $BACKUP_NAME | grep -e '[/.]' &>/dev/null; then
        echo "-!- BACKUP_NAME cannot contain '.' or '/'";
        exit 1;
    elif [ -z "$BACKUP_NAME" ]; then
        echo "-!- You have to define BACKUP_NAME";
        exit 2;
    else
        return 0;
    fi

}

run_me() { #==================================================================

    ### INIT
    PROGRAM=$@;
    EXIT_CODE=-1;

    ### RUN PROGRAM
    if [ -n "$PROGRAM" ]; then

        $PROGRAM;
        EXIT_CODE=$?;

        if [ $EXIT_CODE -ne 0 ]; then
            echo "-!- Program '$PROGRAM' failed with $EXIT_CODE";
        fi

    ### NO PROGRAM TO RUN
    else
        echo "--- No program to run.";
    fi

    ### THE END
    return $EXIT_CODE;
}

touch_logfile() { #===========================================================

    ### INIT
    LOG_FILE="${LOG_DIR}/${BACKUP_NAME}.log";

    if [ ! -d $LOG_DIR ]; then
        mkdir $LOG_DIR || exit 255;
    fi

    if ! touch $LOG_FILE 2>/dev/null; then
        echo "Could not touch \$LOG_FILE ($LOG_FILE)";
        exit 255;
    fi

    ### THE END
    export LOG_FILE;
    return 0;
}

### TEST
if [ "$ACTION" = "test" ]; then
    read_config $2;
    mail_report 0 "Hello World!";


### BACKUP
elif [ "$ACTION" = "day" -o "$ACTION" = "hour" ]; then

    read_config $2;
    check_backup_name;
    touch_logfile;

    LOCK_FILE="/tmp/backup-$BACKUP_NAME";

    ### TRAP
    trap "{                                             \
              rm -f $LOCK_FILE;                         \
              mail_report $EXIT_CODE 'Backup Failed!';  \
          }" SIGINT SIGTERM;
    trap "{                                             \
              rm -f $LOCK_FILE;                         \
          }" EXIT;

    { # send output to tee and logfil

        echo -n "--- Creating backup: "; date;
        echo;

        ### BACKUP DATA
        if ln -s /dev/null $LOCK_FILE &>/dev/null; then

            ### RUN COMMAND BEFORE DOING BACKUP
            run_me $RUN_BEFORE;

            ### RUN RSYNC
            rsync $RSYNC_ARGS $RSYNC_USER_ARGS              \
                  $SRC_DIR                                  \
                  $DST_HOST:$DST_DIR/$BACKUP_NAME/incoming  \
            ; EXIT_CODE=$?;

            if [ $EXIT_CODE -gt 0 ]; then 
	    	echo "Problem with rsync: $EXIT_CODE";
                exit $EXIT_CODE;
            fi

            ### RUN COMMAND AFTER DOING BACKUP
            run_me $RUN_AFTER;

            ### UNLOCK SESSION
            rm $LOCK_FILE;

        ### BACKUP IN PROGRESS
        else
            echo "--- LOCK_FILE ($LOCK_FILE) exists: Backup in progress...";
            mail_report '255' 'LOCK_FILE ($LOCK_FILE) exists!';
            exit 255;
        fi

        ### DONE WITH BACKUP
        echo "--- Done backing up.";

        ### CLEANUP BACKUPS ON REMOTE HOST
        run_me ssh $DST_HOST                \
                   "backup.sh cleanup       \
                              $ACTION       \
                              $DST_DIR      \
                              $BACKUP_NAME  \
                              $KEEP_HOUR    \
                              $KEEP_DAY     \
                   "                        \
        ; EXIT_CODE=$?;

    ### SEND DAILY BACKUP REPORT
    if [ "$ACTION" = "day" ]; then
        mail_report "0" "`cat $LOG_FILE`";
    fi

    } | tee $LOG_FILE

### CLEANUP
elif [ "$ACTION" = "cleanup" ]; then

    ### INIT
    INTERVAL=$2;
    DST_DIR=$3;
    BACKUP_NAME=$4;
    KEEP_HOUR=$5;
    KEEP_DAY=$6;
    INTERVAL_UC=$( echo $INTERVAL | tr a-z A-Z );
    KEEP=$( eval echo "\$KEEP_$INTERVAL_UC" );
    TIMESTAMP=`date +%m%d-%H%M`;

    echo "--- Cleaning up.";

    ### CHECK INPUT
    check_backup_name;
    [ ! -d "$DST_DIR/$BACKUP_NAME" ] && exit 248;

    ### CHANGE WORKING DIR
    echo "--- Changing directory to $DST_DIR/$BACKUP_NAME";
    cd "$DST_DIR/$BACKUP_NAME" || exit 247;

    ### HARDLINK FROM rsync FOLDER
    echo "--- Hardlinking ./incoming to ./$INTERVAL.$TIMESTAMP";
    [ -d ./incoming ]                        || mkdir ./incoming;
    cp -al ./incoming ./$INTERVAL.$TIMESTAMP || exit 246;
    touch             ./$INTERVAL.$TIMESTAMP;

    ### REMOVE OLD BACKUPS
    i=0;
    for dir in `ls -dt $INTERVAL.*`; do
        (( i++ ));
        if [ $i -gt $KEEP ]; then
            echo "--- Removing ./$dir";
            rm -r ./$dir || exit 245;
        fi
    done

    echo "--- Backup list:";
    du -sh *;

    echo "--- Done cleaning.";


### CREATE SSH CERTIFICATE
elif [ "$ACTION" = "keygen" ]; then

    echo "--- Create ssh keys...";
    read_config $2;

    if [ ! -e ~/.ssh/id_dsa.pub ]; then
        ssh-keygen -t dsa;  # creates ~/.ssh/id_dsa.pub
                            # and     ~/.ssh/id_dsa

    else
        echo '-!- Certificate ~/.ssh/id_dsa.pub exists';
    fi

    cat ~/.ssh/id_dsa.pub |               \
    ssh $DST_HOST                         \
        "cat - >> ~/.ssh/authorized_keys" \
    ;

    echo "--- Done createing ssh keys.";

fi


### THE END
exit 0;
