#!/bin/bash

date_folder=$1
start_point=$2
next_step=$(($start_point + 1))



if [ -f "$date_folder/parameters.txt" ]; then
	# this is a experiment folder
	ProcessExperimentDirectory.sh $date_folder $start_point &
else
	# this is not an experiment folder, repeat iteratively
	# loop through all the directories in a date folder

	# log in the master log
	master_log_name=~/logs/masterlog.csv
	current_time=$(date +%F_%T)
	log_entry=ProcessDateDirectory,START,$current_time,$date_folder,HEAD_NODE,$(hostname),'Starting_At:'$(OrderingToScript.sh $next_step)
	echo $log_entry>>$master_log_name

	for folder_name in $date_folder*; do
	    if [ -d ${folder_name} ]; then
	    	# this is a directory
	        # echo $folder_name/
	        ProcessDateDirectory.sh $folder_name/ $start_point &
	    fi
	done
fi
