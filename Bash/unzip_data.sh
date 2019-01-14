#!/bin/bash
folder_name=${1%/}

UpdateLog.sh $folder_name unzip_data $job_ID START Unzipping_Data

#read the last line of the log, get job IX
log_name=$folder_name/status.csv
last_line=$(tac $log_name |egrep -m 1 .)
IFS=',' read -ra ADDR <<< "$last_line"
job_ID=${ADDR[2]}

if test -f $folder_name/raw_images.zip; then 
	# raw images zip exists, extract
	cd $folder_name
	jpg_count=$(($(unzip -u raw_images.zip | wc -l) - 1))
fi

UpdateLog.sh $folder_name unzip_data $job_ID COMPLETE $jpg_count'jpg_files_unzipped'
