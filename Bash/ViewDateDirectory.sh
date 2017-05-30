#!/bin/bash

date_folder=$1
repress_completed=${2:-1}

if [ -f "$date_folder/parameters.txt" ]; then
	# this is a experiment folder
	ViewExperimentDirectory.sh $date_folder $repress_completed
else
	# this is not an experiment folder, repeat iteratively
	# loop through all the directories in a date folder

	for folder_name in $date_folder*; do
	    if [ -d ${folder_name} ]; then
	    	# this is a directory
	        # echo $folder_name/
	        ViewDateDirectory.sh $folder_name/ $repress_completed
	    fi
	done
fi
