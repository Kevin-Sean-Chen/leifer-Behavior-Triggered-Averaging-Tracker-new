#!/bin/bash

date_folder=$1
start_point=$2
next_step=$(($start_point + 1))

# log in the master log
master_log_name=/tigress/LEIFER/Mochi/logs/masterlog.csv
current_time=$(date +%F_%T)
log_entry=ProcessDateDirectory,START,$current_time,$date_folder,HEAD_NODE,$(hostname),'Starting_At:'$(OrderingToScript.sh $next_step)
echo $log_entry>>$master_log_name

# loop through all the directories in a date folder
for folder_name in $date_folder*; do
    if [ -d ${folder_name} ]; then
        # echo $folder_name
        ProcessExperimentDirectory.sh $folder_name $start_point &
    fi
done
