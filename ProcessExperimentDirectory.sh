#!/bin/bash

folder_name=$1
echo $folder_name

# Track the experiment
PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=8000M -t00:30:00 --qos=test TrackExperiment.sh $folder_name)
while squeue -u mochil | grep -q -w ${PROCESS_ID##* }; do sleep 10; done

