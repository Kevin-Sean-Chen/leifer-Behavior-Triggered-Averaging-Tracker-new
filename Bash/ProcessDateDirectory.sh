#!/bin/bash

date_folder=$1

cd /home/mochil/outputs/

# loop through all the directories in a date folder
for f in $date_folder*; do
    if [ -d ${f} ]; then
        echo $f
        #ProcessExperimentDirectory.sh $f &
    fi
done
