#!/bin/bash
cd /tigress/LEIFER/Mochi/github/leifer-Behavior-Triggered-Averaging-Tracker

/usr/licensed/bin/matlab-R2016a -nodisplay -nosplash -nojvm -r "TrackImageDirectory('$1') exit;"

cd /home