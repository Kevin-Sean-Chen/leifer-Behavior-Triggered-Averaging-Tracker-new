#!/bin/bash
export PATH=$PATH:~/github/leifer-Behavior-Triggered-Averaging-Tracker/Bash
output_file_name=~/logs/viewoutput.csv

cd ~/outputs/

rm $output_file_name

ViewDateDirectory.sh /tigress/LEIFER/Mochi/Data/ $1
ViewSortedStatus.sh