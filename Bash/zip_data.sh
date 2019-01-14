#!/bin/bash
folder_name=${1%/}
job_ID=$2

UpdateLog.sh $folder_name zip_data $job_ID START Zipping_Data_And_Deleting_Raw_Images

#get how many jpg files are there
jpg_count=$(ls *.jpg | wc -l)

if [ "$jpg_count" -gt "0" ]; then 
	# jpg file exists, zip them
	zip -m -u raw_images.zip *.jpg
fi

UpdateLog.sh $folder_name delete_tracks $job_ID COMPLETE $jpg_count'jpg_files_zipped'
