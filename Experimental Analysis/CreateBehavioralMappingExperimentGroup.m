% analyzes a group of experiments and saves the properties
% they will be saved inside the first folder
%function LNPStats = CreateBehavioralMappingExperimentGroup(folders)
    %clear all;
    %set up parameters
    recalculateSpectra = false;
    recalculateEmbeddding = false;
    recalculateBehavior = true;
    
    parameters.numProcessors = 15;
    parameters.numProjections = 19;
    parameters.pcaModes = 5;
    parameters.samplingFreq = 14;
    parameters.minF = 0.3;
    parameters.maxF = parameters.samplingFreq ./ 2; %nyquist frequency
    parameters.trainingSetSize = 55000;
    parameters.subsamplingIterations = 10;
    parameters = setRunParameters(parameters);
    Prefs = load_excel_prefs;
    load('reference_embedding.mat')
    number_of_behaviors = max(L(:));
  
    if true%nargin < 1
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
%                 folders = getfoldersGUI();
                folders = getfolders();
            end
        end
    else
        filename = 'temp.mat';
        pathname = '';
        saveFileName = fullfile(pathname,filename);
    end
    
    allTracks = [];
    for folder_index = 1:length(folders)
        %single experiment
        folder_name = folders{folder_index};
        load([folder_name '\tracks.mat'])
        load([folder_name '\LEDVoltages.txt'])
        
        try
            experiment_parameters = load([folder_name '\parameters.txt']);
            frames = experiment_parameters(length(experiment_parameters));
        catch
            experiment_parameters = readtable([folder_name '\parameters.txt'], 'Delimiter', '\t');
            frames = experiment_parameters{1,{'FrameCount'}};
        end
        
        if recalculateBehavior || ~isfield(Tracks, 'BehavioralTransition')
            if recalculateEmbeddding || ~exist([folder_name '\embeddings.mat'], 'file')
                if recalculateSpectra || ~exist([folder_name '\spectra.mat'], 'file')
                    %get the spectra
                    [Spectra, ~, ~, ~] = generate_spectra(Tracks, parameters, Prefs);
                    %save spectra
                    save([folder_name '\spectra.mat'], 'Spectra', '-v7.3');
                else
                    %spectra already found, load it
                    load([folder_name '\spectra.mat']);
                end
                data = vertcat(Spectra{:});
                [embeddingValues,~] = findEmbeddings(data,trainingSetData,trainingEmbedding,parameters);
                clear data
            else
                %embedding already found, load it
                load([folder_name '\embeddings.mat']);
            end
            
            % cut the embeddings
            Tracks(1).Embeddings = []; %preallocate memory
            start_index = 1;
            for track_index = 1:length(Spectra)
                end_index = start_index + size(Spectra{track_index},1) - 1;
                Tracks(track_index).Embeddings = embeddingValues(start_index:end_index, :);
                start_index = end_index + 1;
            end
            
            %get the stereotyped behaviors
            Tracks = find_stereotyped_behaviors(Tracks, L, xx);

            %autosave
            save([folder_name '\tracks.mat'], 'Tracks', '-v7.3');
            %AutoSave(folder_name, Prefs.DefaultPath);
        end

        disp('Calculating Behaviors');
        parfor_progress(Prefs.ProgressDir, round(length(Tracks)/50));
        % Get binary array of when certain behaviors start
        Tracks(1).Behaviors = [];

        parfor track_index = 1:length(Tracks)
            triggers = false(number_of_behaviors, length(Tracks(track_index).LEDVoltages)); %a binary array of when behaviors occur
            for behavior_index = 1:number_of_behaviors
                transition_indecies = Tracks(track_index).BehavioralTransition(:,1) == behavior_index;
                %transition into of
                transition_start_frames = Tracks(track_index).BehavioralTransition(transition_indecies,2);
                triggers(behavior_index,transition_start_frames) = true;
%                 %transition out of
%                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
%                 triggers(behavior_index,transition_end_frames) = true;
            end
            Tracks(track_index).Behaviors = triggers(:,1:length(Tracks(track_index).LEDVoltages));
            if ~mod(track_index/50)
                parfor_progress(Prefs.ProgressDir);
            end
        end
        parfor_progress(Prefs.ProgressDir, 0);
        
        
        if isempty(allTracks)
            allTracks = Tracks;
        else
            allTracks = [allTracks, Tracks];
        end
    end
    
    
    disp('Fitting LNP');
    %the very last entry in Experiments is the average of all experiments
    %fit the LNP
    [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks);

    PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
    save(saveFileName, 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');

 % end