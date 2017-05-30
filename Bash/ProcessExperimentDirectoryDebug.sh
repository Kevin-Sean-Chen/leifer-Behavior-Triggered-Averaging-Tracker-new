#!/bin/bash

folder_name=$1
analysis_starting_point=$2
user_name="$USER"

echo $folder_name

# # check the folder's log what is the last step completed
# step_completed=$(AnalysisProgress.sh $folder_name)
# if [ -z "$step_completed" ]; then
# 	# cannot determine the last step completed
# 	step_completed=-1
# fi

# # if there was no input to the analysis starting point, assume continue analysis
# if [ -z "$analysis_starting_point" ]; then
# 	# cannot determine the last step completed
# 	analysis_starting_point=$step_completed
# fi

# # the actual starting point is the minimum of last step completed and the user defined starting point
# step_to_start=$(($step_completed<$analysis_starting_point?$step_completed:$analysis_starting_point))

# # Update the log to indicate which step the analysis will start on
# next_step=$(($step_to_start + 1))
# # echo $next_step
# UpdateLog.sh $folder_name ProcessExperimentDirectory HEAD_NODE START 'Starting_On:'$(OrderingToScript.sh $next_step)

# # Delete the previous analysis files
# script_name=delete_tracks
# script_order=$(ScriptToOrdering.sh $script_name)
# if [ "$step_to_start" -lt "$script_order" ]; then
# 	# echo deleting
# 	delete_tracks.sh $folder_name 
# fi
# #echo $script_name' finished in '$folder_name

# # Track the experiment
# script_name=track_image_directory
# script_order=$(ScriptToOrdering.sh $script_name)
# if [ "$step_to_start" -lt "$script_order" ]; then
# 	#submit job to cluster
# 	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t00:59:00 RunMatlabNoJVM.sh $folder_name $script_name) #  
# 	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
# 	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
# 	#check if the operation completed succesfully
# 	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
# 	if [ "$exit_command" == "EXIT" ]; then
# 		echo $script_name' failed, exiting in '$folder_name
# 		exit
# 	fi
# fi
# #echo $script_name' finished in '$folder_name


# # Find the centerlines
# script_name=find_centerlines
# script_order=$(ScriptToOrdering.sh $script_name)
# if [ "$step_to_start" -lt "$script_order" ]; then
# 	#submit job to cluster
# 	PROCESS_ID=$(sbatch -N1 -n4 --mem-per-cpu=3000M -t00:59:00 RunMatlabJVM.sh $folder_name $script_name) # 
# 	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
# 	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
# 	#check if the operation completed succesfully
# 	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
# 	if [ "$exit_command" == "EXIT" ]; then
# 		echo $script_name' failed, exiting in '$folder_name
# 		exit
# 	fi
# fi
# #echo $script_name' finished in '$folder_name


# # Auto resolve problems
# script_name=auto_resolve_problems
# script_order=$(ScriptToOrdering.sh $script_name)
# if [ "$step_to_start" -lt "$script_order" ]; then
# 	#submit job to cluster
# 	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t00:59:00 RunMatlabNoJVM.sh $folder_name $script_name) # 
# 	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
# 	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
# 	#check if the operation completed succesfully
# 	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
# 	if [ "$exit_command" == "EXIT" ]; then
# 		echo $script_name' failed, exiting in '$folder_name
# 		exit
# 	fi
# fi
# #echo $script_name' finished in '$folder_name


# # Calculate Behaviors
# script_name=calculate_behaviors
# script_order=$(ScriptToOrdering.sh $script_name)
# if [ "$step_to_start" -lt "$script_order" ]; then
# 	#submit job to cluster
# 	PROCESS_ID=$(sbatch -N1 -n6 --mem-per-cpu=8000M -t00:59:00 RunMatlabJVM.sh $folder_name $script_name) #
# 	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
# 	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
# 	#check if the operation completed succesfully
# 	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
# 	if [ "$exit_command" == "EXIT" ]; then
# 		echo $script_name' failed, exiting in '$folder_name
# 		exit
# 	fi
# fi
# #echo $script_name' finished in '$folder_name


# # Plot the experiment
# script_name=plot_image_directory
# script_order=$(ScriptToOrdering.sh $script_name)
# if [ "$step_to_start" -lt "$script_order" ]; then
# 	#submit job to cluster
# 	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t00:59:00 RunMatlabJVM.sh $folder_name $script_name) # 
# 	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
# 	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
# 	#check if the operation completed succesfully
# 	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
# 	if [ "$exit_command" == "EXIT" ]; then
# 		echo $script_name' failed, exiting in '$folder_name
# 		exit
# 	fi
# fi
# #echo $script_name' finished in '$folder_name


# # # Convert to analysis folders
# # # PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t02:00:00 --mail-type=end --mail-user=mochil@princeton.edu ConvertTracksToAnalysis.sh $folder_name)
# # # while squeue -u mochil | grep -q -w ${PROCESS_ID##* }; do sleep 10; done
