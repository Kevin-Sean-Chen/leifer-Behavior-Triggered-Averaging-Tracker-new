#!/bin/bash
folder_name=$1
script_name=$2
job_ID=$3

log_name=${1%/}/status.csv

master_log_name=~/logs/masterlog.csv

current_time=$(date +%F_%T)

log_header=Script_Name,Status,Time,Folder_Name,JobID,Computer_Name,Comment
log_entry=CreateLog,COMPLETE,$current_time,$folder_name,$job_ID,$(hostname),Log_Initialized

echo $log_header>$log_name
echo $log_entry>>$log_name

echo $log_entry>>$master_log_name
