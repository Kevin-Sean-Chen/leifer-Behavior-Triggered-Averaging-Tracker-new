#!/bin/bash

folder_name=$1
script_name=$2
job_ID=$3

log_name=${1%/}/status.csv

#read the last line of the log
last_line=$(tac $log_name |egrep -m 1 .)
IFS=',' read -ra ADDR <<< "$last_line"
last_script_name=${ADDR[0]}
status=${ADDR[1]}

if [ "$script_name" == "$last_script_name" ] && [ "$status" == "COMPLETE" ]; then
	# the last operation finished successfully
	UpdateLog.sh $folder_name CompletionCheck $job_ID VALIDATE $script_name'_Finished'
	echo CONITNUE
else
	# the last operation was interrupted, log the exit
	UpdateLog.sh $folder_name CompletionCheck $job_ID EXIT $script_name'_Interrupted'
	echo EXIT
fi
