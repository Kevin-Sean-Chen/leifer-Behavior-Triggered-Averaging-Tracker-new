% analyzes a group of experiments and saves the properties
% they will be saved inside the first folder
%function LNPStats = CreateBehavioralMappingExperimentGroup(folders)
    %clear all;
    %set up parameters
    load('reference_embedding.mat')
    relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};
%     relevant_track_fields = {'Behaviors','Frames','LEDPower','LEDVoltages'};

    if true %nargin < 1
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
    
    [allTracks, folder_indecies, ~] = loadtracks(folders,relevant_track_fields);
    
    disp('Fitting LNP');
    %the very last entry in Experiments is the average of all experiments
    %fit the LNP
    [LNPStats, meanLEDPower, stdLEDPower] = directional_FitLNP(allTracks,folder_indecies,folders);
%     [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks,folder_indecies,folders);

    %sort it by the To node
    LNPStats(1).FromNode = [];
    LNPStats(2).ToNode = [];
    for transition_index = 1:length(LNPStats)
        LNPStats(transition_index).FromNode = LNPStats(transition_index).Edges(1);
        LNPStats(transition_index).ToNode = LNPStats(transition_index).Edges(2);
    end
    LNPStats = nestedSortStruct(LNPStats,{'ToNode','FromNode'});
    PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
    
%     PlotDirectionalBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
    save(saveFileName, 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');

% end