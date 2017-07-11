#!/bin/bash
# save the previous logs with the current timestamp and initialize new logs

log_directory=~/logs/
master_log_name=masterlog.csv
error_log_name=errorlog.csv
log_header=Script_Name,Status,Time,Folder_Name,JobID,Computer_Name,Comment


current_time=$(date +"%Y%m%d%H%M")

mv $log_directory$master_log_name $log_directory'z'$current_time$master_log_name
mv $log_directory$error_log_name $log_directory'z'$current_time$error_log_name

echo $log_header>$log_directory$master_log_name
echo $log_header>$log_directory$error_log_name
