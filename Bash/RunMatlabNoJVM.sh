#!/bin/bash
folder_name=$1
script_name=$2

cd ~/github/leifer-Behavior-Triggered-Averaging-Tracker

echo 'running '$script_name

/usr/licensed/bin/matlab-R2016a -nodisplay -nosplash -nojvm -r "call_function('$script_name;$folder_name'); exit;"