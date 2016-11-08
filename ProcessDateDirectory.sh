#!/bin/bash

date_folder=/tigress/LEIFER/Mochi/Pre-cluster-data/CenterlineFinding/20150914/

cd $date_folder

# loop through all the directories in a date folder
for f in *; do
    if [ -d ${f} ]; then
        # analyze the folder
        ProcessExperimentDirectory.sh $date_folder$f &
    fi
done
