#!/bin/bash
folder_name=$1
script_name=$2

cd ~/github/leifer-Behavior-Triggered-Averaging-Tracker

# rm -rf /home/mochil/.matlab

#sleep for an random amount of time in case parallel pool starts on the same node at the same time
sleep $((RANDOM % 100))

/usr/licensed/bin/matlab-R2016a -nodisplay -nosplash -r "call_function('$script_name;$folder_name'); exit;"