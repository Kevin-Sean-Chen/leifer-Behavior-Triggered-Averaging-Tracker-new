% analyzes a group of experiments and saves the properties
% they will be saved inside the first folder
%function LNPStats = CreateBehavioralMappingExperimentGroup(folders)
    %clear all;
    %set up parameters
    recalculateSpectra = false;
    recalculateEmbeddding = false;
    recalculateBehavior = false;
    
    parameters = setRunParameters();
    Prefs = load_excel_prefs;
    load('reference_embedding.mat')
    number_of_behaviors = max(L(:)-1);
  
    if nargin < 1
        [filename,pathname] = uiputfile('*.mat','Save Experiment Group As');

        if isequal(filename,0) || isequal(pathname,0)
            %cancel
           return
        else
            saveFileName = fullfile(pathname,filename);
            if exist(saveFileName, 'file')
              % File exists.  Load the folders
              previously_loaded_experiments = load(saveFileName);
              folders = previously_loaded_experiments.folders;
            else
              % File does not exist. Ask for experiment folders
                folders = getfoldersGUI();
%                folders = getfolders();
            end
        end
    else
        filename = 'temp.mat';
        pathname = '';
        saveFileName = fullfile(pathname,filename);
    end
    
    [allTracks, folder_indecies, track_indecies] = loadtracks(folders);
    
    
    disp('Fitting LNP');
    %the very last entry in Experiments is the average of all experiments
    %fit the LNP
    [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks,folder_indecies,folders);

    PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
    save(saveFileName, 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');

 %end