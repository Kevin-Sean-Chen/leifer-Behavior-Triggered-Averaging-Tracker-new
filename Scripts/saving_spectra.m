%% STEP 1: set up parameters
parameters.numProcessors = 15;
parameters.numProjections = 19;
parameters.pcaModes = 5;
parameters.samplingFreq = 14;
parameters.minF = 0.3;
parameters.maxF = parameters.samplingFreq ./ 2; %nyquist frequency
parameters.trainingSetSize = 55000;
parameters.subsamplingIterations = 10;
parameters = setRunParameters(parameters);
SaveIndividualImages = 1;

%% STEP 2: get the experiment folders
folders = [];
while true
    if isempty(folders)
        start_path = '';
    else
        start_path = fileparts(fullfile(folders{length(folders)}, '..', 'tracks.mat')); %display the parent folder
    end
    folder_name = uigetdir(start_path, 'Select Experiment Folder')
    if folder_name == 0
        break
    else
        folders{length(folders)+1} = folder_name;
    end
end
%% STEP 2: Load the analysis preferences from Excel %%
'Initializing...'
if ~exist('Prefs', 'var')
    Prefs = load_excel_prefs();
end


%% STEP 3: load the tracks into memory
allTracks = struct([]);
folder_indecies = [];
track_indecies = [];

for folder_index = 1:length(folders)
    curDir = folders{folder_index};
    if exist([curDir, '\tracks.mat'], 'file') == 2
        load([curDir, '\tracks.mat'])
        allTracks = [allTracks, Tracks];
        folder_indecies = [folder_indecies, repmat(folder_index,1,length(Tracks))];
        track_indecies = [track_indecies, 1:length(Tracks)];
    end
end
L = length(allTracks);
clear('Tracks');


%% STEP 4: generate spectra
poolobj = gcp('nocreate'); 
if isempty(poolobj)
    parpool(parameters.numProcessors)
end

[Spectra, SpectraFrames, SpectraTracks, f] = generate_spectra(allTracks, parameters, Prefs);

poolobj = gcp('nocreate'); 
delete(poolobj);
f = fliplr(f);

allTracks(1).Spectra = [];
allTracks(1).Images = [];
for track_index = 1:length(allTracks)
    image_file = fullfile([folders{1}, '\individual_worm_imgs\worm_', num2str(track_indecies(track_index)), '.mat']);
    load(image_file);
    allTracks(track_index).Images = worm_images;
    allTracks(track_index).Spectra = Spectra{track_index};
end

folder_name = folders{1};
saveFileName = [folder_name '\spectra_all_tracks.mat'];
save(saveFileName, 'allTracks');
