#!/bin/bash
folder_name=${1%/}
job_ID=$2

UpdateLog.sh $folder_name zip_data $job_ID START Zipping_Data_And_Deleting_Raw_Images

#get how many jpg files are there
jpg_count=$(ls $folder_name/*.jpg | wc -l)

if [ "$jpg_count" -gt "0" ]; then 
	# jpg file exists, zip them
	cd $folder_name
	zip -m -u raw_images.zip *.jpg > /dev/null
fi

UpdateLog.sh $folder_name zip_data $job_ID COMPLETE $jpg_count'_jpg_files_zipped'
