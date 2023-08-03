# leifer-Behavior-Triggered-Averaging-Tracker-new

This is a repo for high-throughput worm tracking in the Leifer lab. The -new repo is edited to track worm behavior in the odor flow chamber, characterizing chemotaxis behavior in a large arena.

The pipeline is used to process raw recordings of C. elegans navigation behavior, as published in: eLife2023;12:e85910 DOI: https://doi.org/10.7554/eLife.85910 (Continuous odor profile monitoring to study olfactory navigation in small animals. Chen, Wu, et al. 2023.)

## Running experiments

Use Labview vi in `LabviewVIs` folder to run experiments in real-time. For the full odor navigation project, please check repo https://github.com/GershowLab/OdorSensorArray for control and communication with other devises. In the LabviewVIs folder, run `gaussian correlation time.vi` for recording or white-noise optogenetic stimuli. Run `array_light_mix.vi` to deliver optogenetic impulse.

## Submitting pipeline jobs

Use the `Bash` scripts to submit the analysis pipeline to the computing cluster Della at Princeton. Specifically, use `cluster_run.sh` to run all or `ProcessExperimentatDirectory.sh` to run a specific data folder.

Use `View ExperimentDirectory.sh` to check the experiment files and use `cluster_view.sh` to check currently running jobs.

## Debugging

Use functions in the `debuggingTools` folder to plot images. Double check with the `parameters.csv` spreadsheet for tracking and devise parameters.

## Track analysis

Use scripts in `TrackAnalysis` folder to identify behavioral modes along the worm track. For further analysis, please check repo https://github.com/GershowLab/OdorSensorArray with scripts in `matlab_data analysis` to analyze chemotaxis behavior.

## Citation

If you use the design files and/or codes provided in this repository, please cite:
> Kevin S. Chen, Rui Wu, Marc H. Gershow, Andrew M. Leifer. (2023). Continuous odor profile monitoring to study olfactory navigation in small animals. eLife. DOI: https://doi.org/10.7554/eLife.85910

## Lisence
Design files and codes provided in this repository are free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This repository is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
