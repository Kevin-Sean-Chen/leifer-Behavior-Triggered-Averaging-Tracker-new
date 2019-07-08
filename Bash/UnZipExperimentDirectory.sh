#!/bin/bash

folder_name=$1
user_name="$USER"

echo $folder_name


# zip the raw image files if applicable

PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t01:59:00 unzip_data.sh $folder_name) #  


#echo $script_name' finished in '$folder_name

# # Convert to analysis folders
# # PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t02:00:00 --mail-type=end --mail-user=mochil@princeton.edu ConvertTracksToAnalysis.sh $folder_name)
# # while squeue -u mochil | grep -q -w ${PROCESS_ID##* }; do sleep 10; done
