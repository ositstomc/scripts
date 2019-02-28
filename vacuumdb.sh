#!/bin/bash
##################################################
# Vacuum Database script
#
#
# Change Control
# 27-MAY-2018 : TOMC : created
##################################################


DATABASE=rt3
DBUSER=postgres
LOG_FOLDER=/opt/stf/logs
LOG_FILE=db_vacuum-$DATABASE-`date +%Y-%m-%d`.log
REVISION=1
declare -a arr=("sendmail")

echo `date '+%Y-%m-%d %H:%M:%S'` [INFO] Starting...>> $LOG_FOLDER/$LOG_FILE

COUNTER=2
while [ $COUNTER -gt 0  ]
do
        for i in "${arr[@]}"
        do
                if pgrep -x "$i" > /dev/null
                then
                        echo "$i running"
                        service "$i" stop
                else
                        echo "$i stopped"
                        echo `date '+%Y-%m-%d %H:%M:%S'` [INFO] "$i service stopped.">> $LOG_FOLDER/$LOG_FILE
                        COUNTER=$(( $COUNTER - 1 ))
                fi
        done
done

echo "Services have been stopped" | mail -s "VacuumDB"   tomc@email.com

RESULT=vacuumdb -U $DBUSER $DATABASE –full
if [[ $RESULT = *"failed"* ]]; then
                echo `date '+%Y-%m-%d %H:%M:%S'` [ERROR] "Vacuumdb exited with an error.">> $LOG_FOLDER/$LOG_FILE
                echo "It's there!"
        else
                echo `date '+%Y-%m-%d %H:%M:%S'` [INFO] "Vacuumdb has completed.">> $LOG_FOLDER/$LOG_FILE
fi


COUNTER=2
while [ $COUNTER -gt 0  ]
do
        for i in "${arr[@]}"
        do
                if ! pgrep -x "$i" > /dev/null
                then
                        service "$i" start
                else
                        echo `date '+%Y-%m-%d %H:%M:%S'` [INFO] "$i service started.">> $LOG_FOLDER/$LOG_FILE
                        COUNTER=$(( $COUNTER - 1 ))
                fi
        done
done
echo "Services are running" | mail -s "VacuumDB"   tomc@email.com





GREPCOUNT=`grep -c -i 'ERROR' $LOG_FOLDER/$LOG_FILE`
if [ $GREPCOUNT -gt 0 ]; then
  echo "Errors have been detected" | mail -S "VacuumDB" -r "tomc@email.com" -a "$LOG_FOLDER/$LOG_FILE" tomc@email.com
fi
