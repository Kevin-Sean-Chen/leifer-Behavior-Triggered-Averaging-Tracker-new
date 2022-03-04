#!/bin/bash
cd ~/github/leifer-Behavior-Triggered-Averaging-Tracker

echo 'converting tracks to analysis folders'

/usr/licensed/bin/matlab-R2019b -nodisplay -nosplash -nojvm -r "convert_tracks_to_analysis('$1'); exit;"