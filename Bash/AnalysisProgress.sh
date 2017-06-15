#!/bin/bash
# This function looks at the status.csv log file backwards until reaching the last step of the analysis that was completed by MATLAB
# Returns empty nothing has been completed so far
folder_name=$1

log_name=${1%/}/status.csv

if ! test -w $log_name; then 
	# log file does not exist, create it and exit
	CreateLog.sh $1 $2 $3
	exit
fi

tac $log_name | while read line; do
	#read the file backwards until we find the last step that was actually completed
	IFS=',' read -ra ADDR <<< "$line"
	script_name=${ADDR[0]}
	status=${ADDR[1]}

	if [ "$status" == "COMPLETE" ]; then
		potential_last_step_completed=$(ScriptToOrdering.sh $script_name)
		if [ "$potential_last_step_completed" -gt "-1" ]; then
			# the last thing completed by MATLAB
			echo $potential_last_step_completed
			break
		fi
	fi
done