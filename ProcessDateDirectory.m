    
%% STEP 1: Get folders
folders = {};
folder_count = 0;
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        allFiles = dir(); %get all the tif files
        for file_index = 1:length(allFiles)
            if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
                folder_count = folder_count + 1;
                folders{folder_count} = [folder_name, '\', allFiles(file_index).name];
            end
        end
    end
end

%% STEP 2: Load the analysis preferences from Excel %%
'Initializing...'
if ~exist('Prefs', 'var') || ~exist('WormTrackerPrefs', 'var')
    [~, ComputerName] = system('hostname'); %get the computer name

    %Get Tracker default Prefs from Excel file
    ExcelFileName = 'Worm Tracker Preferences';
    WorkSheet = 'Tracker Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    for computer_index = 1:size(T,2)
        if strcmp(T{1,computer_index}, strtrim(ComputerName))
            break
        end
    end
    computer_index = computer_index - 1; % the first column does not count
    WormTrackerPrefs.MinWormArea = N(1,computer_index);
    WormTrackerPrefs.MaxWormArea = N(2,computer_index);
    WormTrackerPrefs.MaxDistance = N(3,computer_index);
    WormTrackerPrefs.SizeChangeThreshold = N(4,computer_index);
    WormTrackerPrefs.MinTrackLength = N(5,computer_index);
    WormTrackerPrefs.AutoThreshold = N(6,computer_index);
    WormTrackerPrefs.CorrectFactor = N(7,computer_index);
    WormTrackerPrefs.ManualSetLevel = N(8,computer_index);
    WormTrackerPrefs.DarkObjects = N(9,computer_index);
    WormTrackerPrefs.PlotRGB = N(10,computer_index);
    WormTrackerPrefs.PauseDuringPlot = N(11,computer_index);
    WormTrackerPrefs.PlotObjectSizeHistogram = N(12,computer_index);
    if exist(T{14,computer_index+1}, 'file')
        get the mask
       WormTrackerPrefs.Mask = imread(T{14,computer_index+1}); 
    else
       WormTrackerPrefs.Mask = 0;
    end
    WormTrackerPrefs.MaxObjects = N(14,computer_index);
    WormTrackerPrefs.PlottingFrameRate = N(15,computer_index);

    WorkSheet = 'Analysis Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    for computer_index = 1:size(T,2)
        if strcmp(T{1,computer_index}, strtrim(ComputerName))
            break
        end
    end
    computer_index = computer_index - 1; % the first column does not count
    Prefs.SampleRate = N(1,computer_index);
    Prefs.SmoothWinSize = N(2,computer_index);
    Prefs.StepSize = N(3,computer_index);
    Prefs.PlotDirection = N(4,computer_index);
    Prefs.PlotSpeed = N(5,computer_index);
    Prefs.PlotAngSpeed = N(6,computer_index);
    Prefs.PirThresh = N(7,computer_index);
    Prefs.MaxShortRun = N(8,computer_index);
    Prefs.FFSpeed = N(9,computer_index);
    Prefs.PixelSize = 1/N(10,computer_index);
    Prefs.BinSpacing = N(11,computer_index);
    Prefs.MaxSpeedBin = N(12,computer_index);
    Prefs.P_MaxSpeed = N(13,computer_index);
    Prefs.P_TrackFraction = N(14,computer_index);
    Prefs.P_WriteExcel = N(15,computer_index);
    Prefs.MinDisplacement = N(17,computer_index);
    Prefs.PirSpeedThresh = N(18,computer_index);
    Prefs.EccentricityThresh = N(19,computer_index);
    Prefs.PauseSpeedThresh = N(20,computer_index);
    Prefs.MinPauseDuration = N(21,computer_index);   
    Prefs.MaxBackwardsFrames = N(22,computer_index) * Prefs.SampleRate;
    Prefs.DefaultPath = T{17,computer_index+1};
    Prefs.ImageSize = [N(23,computer_index), N(23,computer_index)];   
    Prefs.ProgressDir = pwd;
end
%% STEP 3: Get a rough estimate of how much work needs to be done %%
total_image_files = 0;
for folder_index = 1:folder_count
    curDir = folders{folder_index};
    image_files = dir([curDir, '\*.tif']);
    total_image_files = total_image_files + length(image_files);
end
% 
% %% STEP 3: Track and save the individual worm images %%
% 'Tracking...'
% poolobj = gcp('nocreate'); 
% if isempty(poolobj)
%     parpool(4)
% end
% parfor_progress(Prefs.ProgressDir, round(total_image_files/50));
% parfor folder_index = 1:folder_count
%     folder_name = folders{folder_index};
%     TrackImageDirectory(folder_name, 'all', WormTrackerPrefs, Prefs);
% end
% parfor_progress(Prefs.ProgressDir, 0);
% poolobj = gcp('nocreate'); 
% delete(poolobj);

%% STEP 4: Find centerlines %%
'Getting Centerlines...'
poolobj = gcp('nocreate'); 
if isempty(poolobj)
    parpool(7)
end
for folder_index = 1:folder_count
    curDir = folders{folder_index}
    if exist([curDir, '\tracks.mat'], 'file') == 2
        load([curDir, '\tracks.mat'])
        Tracks = Find_Centerlines(Tracks, curDir);
    end
    saveFileName = [curDir '\tracks.mat'];
    save(saveFileName, 'Tracks');
    AutoSave(curDir, Prefs.DefaultPath);
end 
poolobj = gcp('nocreate'); 
delete(poolobj);

%% STEP 5: Plot
'Plotting...'
for folder_index = 1:folder_count
    curDir = folders{folder_index};
    PlotImageDirectory(curDir, WormTrackerPrefs, Prefs);
end 
