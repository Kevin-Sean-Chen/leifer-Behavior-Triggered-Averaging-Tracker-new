#!/bin/bash

date_folder=$1
start_point=$2

# loop through all the directories in a date folder
for folder_name in $date_folder*; do
    if [ -d ${folder_name} ]; then
        # echo $folder_name
        ProcessExperimentDirectory.sh $folder_name $start_point &
    fi
done
