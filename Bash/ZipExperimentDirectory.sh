#!/bin/bash

folder_name=$1
analysis_starting_point=$2
user_name="$USER"

echo $folder_name


# zip the raw image files if applicable
script_name=zip_data
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	#submit job to cluster
	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t01:59:00 zip_data.sh $folder_name) #  
	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
	#check if the operation completed succesfully
	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
	if [ "$exit_command" == "EXIT" ]; then
		echo $script_name' failed, exiting in '$folder_name
		exit
	fi
fi

#echo $script_name' finished in '$folder_name

# # Convert to analysis folders
# # PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t02:00:00 --mail-type=end --mail-user=mochil@princeton.edu ConvertTracksToAnalysis.sh $folder_name)
# # while squeue -u mochil | grep -q -w ${PROCESS_ID##* }; do sleep 10; done
