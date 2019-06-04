#!/bin/bash

date_folder=$1


if [ -f "$date_folder/parameters.txt" ]; then
	# this is a experiment folder
	ZipExperimentDirectory.sh $date_folder &
else
	# this is not an experiment folder, repeat iteratively
	# loop through all the directories in a date folder

	for folder_name in $date_folder*; do
	    if [ -d ${folder_name} ]; then
	    	# this is a directory
	        # echo $folder_name/
	        ZipDateDirectory.sh $folder_name/ &
	    fi
	done
fi
