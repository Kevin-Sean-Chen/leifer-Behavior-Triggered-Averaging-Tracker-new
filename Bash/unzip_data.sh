#!/bin/bash
folder_name=${1%/}
job_ID=$2

UpdateLog.sh $folder_name unzip_data $job_ID START Unzipping_Data

if test -f $folder_name/raw_images.zip; then 
	# raw images zip exists, extract
	jpg_count=$(unzip -u $folder_name/raw_images.zip -d $folder_name/ | wc -l)
fi

UpdateLog.sh $folder_name unzip_data $job_ID COMPLETE $jpg_count'jpg_files_unzipped'
