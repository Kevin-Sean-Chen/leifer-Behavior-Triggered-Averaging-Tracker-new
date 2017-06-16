#!/bin/bash
export PATH=$PATH:~/github/leifer-Behavior-Triggered-Averaging-Tracker/Bash

#start_point=-1 #redo everything
start_point=$(ScriptToOrdering.sh max) #continue analysis
#start_point=$(($start_point + 1))
#start_point=3

echo $start_point

cd ~/outputs/

InitalizeLogs.sh

ProcessDateDirectory.sh /tigress/LEIFER/Mochi/Data/ $start_point