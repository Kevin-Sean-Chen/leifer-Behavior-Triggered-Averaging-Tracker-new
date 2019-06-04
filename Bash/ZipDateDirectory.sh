#!/bin/bash

date_folder=$1
start_point=$2
next_step=$(($start_point + 1))



if [ -f "$date_folder/parameters.txt" ]; then
	# this is a experiment folder
	ZipExperimentDirectory.sh $date_folder $start_point &
else
	# this is not an experiment folder, repeat iteratively
	# loop through all the directories in a date folder

	for folder_name in $date_folder*; do
	    if [ -d ${folder_name} ]; then
	    	# this is a directory
	        # echo $folder_name/
	        ZipDateDirectory.sh $folder_name/ $start_point &
	    fi
	done
fi
