#!/bin/bash
dte=`date +%Y-%m-%d`
logdir="/var/log/"
logfile=$logdir"app_restart_"$dte.log
proc=exp-server.jar
serv=exp
clear
echo "INFO $dte" >> $logfile
echo "INFO Starting script"  >> $logfile

proc_count=$(ps -ef | grep $proc | wc -l)
if [ $proc_count -ge 2  ]
then
        echo INFO $serv is running  >> $logfile
        systemctl stop $serv
        echo INFO Stopping $serv >> $logfile
        while [ $proc_count -ge 2 ]
        do
                sleep 10
                proc_count=$(ps -ef | grep $proc | wc -l)
        done
        echo INFO $serv has stopped  >> $logfile
else
        echo ERROR $serv is not running  >> $logfile
fi


echo INFO Starting $serv >> $logfile
systemctl start $serv
sleep 20

proc_count=$(ps -ef | grep $proc | wc -l)
if [ $proc_count -ge 2  ]
then
        echo INFO $serv has started again  >> $logfile
fi
sleep 500
cat /var/lib/stf/exp/logs/exp.log | grep "Started expApplication" | cut -d' ' --complement -s -f1-2 >> $logfile
echo "*************************" >> $logfile