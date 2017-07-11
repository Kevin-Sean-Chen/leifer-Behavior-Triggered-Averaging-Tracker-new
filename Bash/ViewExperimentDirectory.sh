#!/bin/bash
output_file_name=~/logs/viewoutput.csv
folder_name=$1
repress_completed=$2
log_name=${1%/}/status.csv

if ! test -w $log_name; then 
	# log file does not exist, create it and exit
	
	exit
fi

#read the last line of the log
last_line=$(tac $log_name |egrep -m 1 .)
IFS=',' read -ra ADDR <<< "$last_line"
last_script_name=${ADDR[0]}
status=${ADDR[1]}
time_stamp=${ADDR[2]}
jobID=${ADDR[4]}
comment=${ADDR[6]}

#get the time difference from now and before
no_underscore_time_stamp=${time_stamp//_/ }
time_in_sec=$(date -d "$no_underscore_time_stamp" +'%s')
current_time_in_sec=$(date +%s)
time_diff=$(date -u -d "0 $current_time_in_sec seconds - $time_in_sec seconds" +"%H:%M:%S")
sec_diff=$((current_time_in_sec - time_in_sec))
day_diff=$((sec_diff / 86400))

# check the folder's log what is the last step completed
step_completed=$(AnalysisProgress.sh $folder_name)
if [ -z "$step_completed" ]; then
	# cannot determine the last step completed
	step_completed=0
fi
last_step=$(ScriptToOrdering.sh max)
if [ "$step_completed" -ge "$last_step" ]; then
	#we are done last character is a stop!
	progress_bar=$(PrintProgressBar.sh $step_completed)'|'
	completed=1
else
	progress_bar=$(PrintProgressBar.sh $step_completed)'>'
	completed=0
fi


short_folder_name=$(basename $folder_name)

if [[ ("$completed" == 0 ) || ( "$repress_completed" == 0) ]]; then
	echo $short_folder_name' '$progress_bar' '$last_script_name' '$status' '$comment' '$day_diff'-'$time_diff' '$jobID>>$output_file_name
fi