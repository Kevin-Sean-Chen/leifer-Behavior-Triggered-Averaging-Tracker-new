#!/bin/bash
output_file_name=~/logs/viewoutput.csv
sorted_output_file_name=~/logs/sortedviewoutput.csv

#sort the ouputs
sort -k2,2 -k3,3 -k4,4 -k5,5 -k6,6 $output_file_name>$sorted_output_file_name

#add header
echo 'Folder_Name Progress_Bar Script_Name Status Comment Time_Since JobID' | cat - $sorted_output_file_name > temp && mv temp $sorted_output_file_name

#print out the file
cat $sorted_output_file_name | column -t
