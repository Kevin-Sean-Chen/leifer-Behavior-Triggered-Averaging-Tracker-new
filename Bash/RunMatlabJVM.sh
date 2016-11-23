#!/bin/bash
folder_name=$1
script_name=$2

cd /home/mochil/github/leifer-Behavior-Triggered-Averaging-Tracker

/usr/licensed/bin/matlab-R2016a -nodisplay -nosplash -r "call_function('$script_name;$folder_name'); exit;"