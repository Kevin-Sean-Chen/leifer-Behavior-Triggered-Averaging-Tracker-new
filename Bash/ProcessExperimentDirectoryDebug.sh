
# Delete the previous analysis files
script_name=delete_tracks
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	echo deleting
	delete_tracks.sh $folder_name 
fi
echo $script_name' finished in '$folder_name

# Track the experiment
script_name=track_image_directory
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	#submit job to cluster
	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t00:59:00 --mail-type=end --mail-user=mochil@princeton.edu RunMatlabNoJVM.sh $folder_name $script_name) # -t12:00:00 
	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
	#check if the operation completed succesfully
	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
	if [ "$exit_command" == "EXIT" ]; then
		echo $script_name' failed, exiting'
		exit
	fi
fi
echo $script_name' finished in '$folder_name


# Find the centerlines
script_name=find_centerlines
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	#submit job to cluster
	PROCESS_ID=$(sbatch -N1 -n4 --mem-per-cpu=3000M -t00:59:00 --mail-type=end --mail-user=mochil@princeton.edu RunMatlabJVM.sh $folder_name $script_name) #-t23:00:00 
	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
	#check if the operation completed succesfully
	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
	if [ "$exit_command" == "EXIT" ]; then
		echo $script_name' failed, exiting'
		exit
	fi
fi
echo $script_name' finished in '$folder_name


# Auto resolve problems
script_name=auto_resolve_problems
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	#submit job to cluster
	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t00:59:00 --mail-type=end --mail-user=mochil@princeton.edu RunMatlabNoJVM.sh $folder_name $script_name) #-t23:00:00 
	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
	#check if the operation completed succesfully
	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
	if [ "$exit_command" == "EXIT" ]; then
		echo $script_name' failed, exiting'
		exit
	fi
fi
echo $script_name' finished in '$folder_name


# Calculate Behaviors
script_name=calculate_behaviors
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	#submit job to cluster
	PROCESS_ID=$(sbatch -N1 -n6 --mem-per-cpu=8000M -t00:59:00 --mail-type=end --mail-user=mochil@princeton.edu RunMatlabJVM.sh $folder_name $script_name) #-t23:00:00
	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
	#check if the operation completed succesfully
	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
	if [ "$exit_command" == "EXIT" ]; then
		echo $script_name' failed, exiting'
		exit
	fi
fi
echo $script_name' finished in '$folder_name


# Plot the experiment
script_name=plot_image_directory
script_order=$(ScriptToOrdering.sh $script_name)
if [ "$step_to_start" -lt "$script_order" ]; then
	#submit job to cluster
	PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t00:59:00 --mail-type=end --mail-user=mochil@princeton.edu RunMatlabJVM.sh $folder_name $script_name) #-t04:00:00 
	UpdateLog.sh $folder_name $script_name ${PROCESS_ID##* } SUBMIT Awaiting_Resources #update the log
	while squeue -u $user_name | grep -q -w ${PROCESS_ID##* }; do sleep 10; done #wait until job finishes
	#check if the operation completed succesfully
	exit_command=$(CompletionCheck.sh $folder_name $script_name ${PROCESS_ID##* }) 
	if [ "$exit_command" == "EXIT" ]; then
		echo $script_name' failed, exiting'
		exit
	fi
fi
echo $script_name' finished in '$folder_name


# # Convert to analysis folders
# # PROCESS_ID=$(sbatch -N1 -n1 --mem-per-cpu=4000M -t02:00:00 --mail-type=end --mail-user=mochil@princeton.edu ConvertTracksToAnalysis.sh $folder_name)
# # while squeue -u mochil | grep -q -w ${PROCESS_ID##* }; do sleep 10; done
