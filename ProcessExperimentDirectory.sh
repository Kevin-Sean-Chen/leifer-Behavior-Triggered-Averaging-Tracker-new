#!/bin/bash

folder_name=$1
echo $folder_name

# Find the centerlines
PROCESS_ID=$(sbatch -N1 -n8 --mem-per-cpu=2000M -t00:30:00 --qos=test --mail-type=end --mail-user=mochil@princeton.edu FindCenterlines.sh $folder_name)
while squeue -u mochil | grep -q -w ${PROCESS_ID##* }; do sleep 10; done