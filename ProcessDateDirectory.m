% analysis options
tracking = 1;
finding_centerline = 1;
resolving_problems =1;
plotting = 1;
SaveIndividualImages = 1;

%% STEP 1: Get folders
folders = {};
folder_count = 0;
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        if exist([folder_name, '\LEDVoltages.txt'],'file')
            %this is a image folder
            folder_count = folder_count + 1;
            folders{folder_count} = folder_name;
        else
            cd(folder_name) %open the date directory
            allFiles = dir(); %get all the subfolders
            for file_index = 1:length(allFiles)
                if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
                    folder_count = folder_count + 1;
                    folders{folder_count} = [folder_name, '\', allFiles(file_index).name];
                end
            end
        end
    end
end

%% STEP 2: Load the analysis preferences from Excel %%
'Initializing...'
if ~exist('Prefs', 'var')
    Prefs = load('EigenVectors.mat'); %load eigenvectors for eigenworms
    Prefs.SaveIndividualImages = SaveIndividualImages;
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
    Prefs.MinWormArea = N(1,computer_index);
    Prefs.MaxWormArea = N(2,computer_index);
    Prefs.MaxDistance = N(3,computer_index);
    Prefs.SizeChangeThreshold = N(4,computer_index);
    Prefs.MinTrackLength = N(5,computer_index);
    Prefs.AutoThreshold = N(6,computer_index);
    Prefs.CorrectFactor = N(7,computer_index);
    Prefs.ManualSetLevel = N(8,computer_index);
    Prefs.DarkObjects = N(9,computer_index);
    Prefs.PlotRGB = N(10,computer_index);
    Prefs.PauseDuringPlot = N(11,computer_index);
    Prefs.PlotObjectSizeHistogram = N(12,computer_index);
    if exist(T{14,computer_index+1}, 'file')
       %get the mask
       Prefs.Mask = imread(T{14,computer_index+1}); 
    else
       Prefs.Mask = 0;
    end
    Prefs.MaxObjects = N(14,computer_index);
    Prefs.PlottingFrameRate = N(15,computer_index);
    Prefs.IndividualVideoPlottingFrameRate = N(16,computer_index);
    
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
    Prefs.MinAverageWormArea = N(24,computer_index);
    Prefs.ProgressDir = pwd;
end


%% STEP 3: Track and save the individual worm images %%
if tracking
    'Tracking...'
    %Get a rough estimate of how much work needs to be done
    total_image_files = 0;
    for folder_index = 1:folder_count
        curDir = folders{folder_index};
        image_files = dir([curDir, '\*.tif']);
        total_image_files = total_image_files + length(image_files);
    end
    
    if folder_count > 1
        %use parfor
        poolobj = gcp('nocreate'); 
        if isempty(poolobj)
            parpool(min(4, folder_count))
        end
        parfor_progress(Prefs.ProgressDir, round(total_image_files/50));
        parfor folder_index = 1:folder_count
            folder_name = folders{folder_index};
            TrackImageDirectory(folder_name, 'analysis', Prefs);
        end
        parfor_progress(Prefs.ProgressDir, 0);
        poolobj = gcp('nocreate'); 
        delete(poolobj);
    else
        parfor_progress(Prefs.ProgressDir, round(total_image_files/50));
        for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            TrackImageDirectory(folder_name, 'all', Prefs);
        end
        parfor_progress(Prefs.ProgressDir, 0);
    end
end

%% STEP 4: Find centerlines %%
if finding_centerline
    'Getting Centerlines...'
    poolobj = gcp('nocreate'); 
    if isempty(poolobj)
        parpool(7)
    end
    for folder_index = 1:folder_count
        curDir = folders{folder_index}
        if exist([curDir, '\tracks.mat'], 'file') == 2
            load([curDir, '\tracks.mat'])
            Tracks = Find_Centerlines(Tracks, curDir, Prefs);
            saveFileName = [curDir '\tracks.mat'];
            save(saveFileName, 'Tracks');
            AutoSave(curDir, Prefs.DefaultPath);
        end

    end 
    poolobj = gcp('nocreate'); 
    delete(poolobj);
end

%% STEP 6: Resolve problems
if resolving_problems
    'Resolve Issues'
    for folder_index = 1:folder_count
        curDir = folders{folder_index}

        Tracks = auto_resolve_problems(curDir, Prefs);
        saveFileName = [curDir '\tracks.mat'];
        save(saveFileName, 'Tracks');
        AutoSave(curDir, Prefs.DefaultPath);
    end 
end

%% STEP 7: Plot
if plotting
    'Plotting...'
    for folder_index = 1:folder_count
        curDir = folders{folder_index};
        PlotImageDirectory(curDir, Prefs);
    end 
end