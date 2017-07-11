#!/bin/bash
folder_name=$1
script_name=$2
job_ID=$3
status=$4
comment=$5

log_name=${1%/}/status.csv

master_log_name=~/logs/masterlog.csv
error_log_name=~/logs/errorlog.csv

current_time=$(date +%F_%T)

if ! test -w $log_name; then 
	# log file does not exist, create it
	CreateLog.sh $1 $2 $3
fi

log_entry=$script_name,$status,$current_time,$folder_name,$job_ID,$(hostname),$comment

# append to the logs
echo $log_entry>>$log_name
echo $log_entry>>$master_log_name

if [ "$status" == "ERROR" ] || [ "$status" == "EXIT" ] ; then
	# append to the error log
	echo $log_entry>>$error_log_name
fi