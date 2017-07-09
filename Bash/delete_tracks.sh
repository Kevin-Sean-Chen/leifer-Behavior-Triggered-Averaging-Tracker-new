#!/bin/bash
folder_name=${1%/}
UpdateLog.sh $folder_name delete_tracks HEAD_NODE START Deleting_Analysis_Files

declare -a files_removed
count=0

files_to_remove=(
     'tracks.mat'
     'processed.avi'
     'processed.mp4'
     'embeddings.mat'
     'spectra.mat'
   )

# remove all the files in the analysis folder
if test -d $folder_name/analysis; then
	# keep track of which analysis files are deleted
	for analysis_file in $folder_name/analysis/*; do
		file_name=$(basename $analysis_file)
		files_removed[$count]=$file_name
		rm $analysis_file
 		count=$(( $count + 1 ))
	done
	rmdir $folder_name/analysis
fi

# remove the entire individual_worm_images folder
if test -d $folder_name/individual_worm_imgs; then
	# only keep track of if individual_worm_imgs folder is deleted
	files_removed[$count]=individual_worm_imgs
	rm -r $folder_name/individual_worm_imgs
	count=$(( $count + 1 ))
fi


#conditional testing of a couple of files that might exist to delete
for file_name in ${files_to_remove[@]}; do
	if test -f $folder_name/$file_name; then 
		# file exists
		files_removed[$count]=$file_name
		rm $folder_name/$file_name
		count=$(( $count + 1 ))
	fi
done

IFS='|';files_removed_cat="${files_removed[*]// /|}";IFS=$' \t\n'

UpdateLog.sh $folder_name delete_tracks HEAD_NODE COMPLETE $files_removed_cat