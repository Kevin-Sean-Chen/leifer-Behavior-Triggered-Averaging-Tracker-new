#!/bin/bash

date_folder=$1

# loop through all the directories in a date folder
for folder_name in $date_folder*; do
    if [ -d ${folder_name} ]; then
        # echo $folder_name
        ViewExperimentDirectory.sh $folder_name
    fi
done
