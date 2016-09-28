% analyzes a group of experiments and saves the properties
% they will be saved inside the first folder
% function LNPStats = CreateBehavioralMappingExperimentGroup(folders)
    %clear all;
    %set up parameters
    recalculateSpectra = false;

   
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
    number_of_behaviors = max(L(:)-1);
  
    max_frame_number = 30*60*parameters.samplingFreq;
    number_of_sections = 3;
    
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
                folders = getfoldersGUI();
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
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        load('LEDVoltages.txt')
        
        try
            experiment_parameters = load('parameters.txt');
            frames = experiment_parameters(length(experiment_parameters));
        catch
            experiment_parameters = readtable('parameters.txt', 'Delimiter', '\t');
            frames = experiment_parameters{1,{'FrameCount'}};
        end
        
        if recalculateSpectra || ~isfield(Tracks, 'BehavioralTransition')
            %get the spectra
            [Spectra, ~, ~, ~] = generate_spectra(Tracks, parameters, Prefs);
            
            %save spectra
            save([folder_name '\spectra.mat'], 'Spectra', '-v7.3');
            
            data = vertcat(Spectra{:});
            [embeddingValues,~] = findEmbeddings(data,trainingSetData,trainingEmbedding,parameters);
            clear data

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
            AutoSave(folder_name, Prefs.DefaultPath);
        end

        % Get binary array of when certain behaviors start
        Tracks(1).Behaviors = [];
        for track_index = 1:length(Tracks)
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
        end

        if isempty(allTracks)
            allTracks = Tracks;
        else
            allTracks = [allTracks, Tracks];
        end
    end
    
    
    for section_index = 1:number_of_sections
        start_frame = (section_index-1)*max_frame_number/number_of_sections+1;
        end_frame = section_index*max_frame_number/number_of_sections;
        
        [section_Tracks, section_track_indecies] = FilterTracksByTime(allTracks,start_frame,end_frame);
        [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(section_Tracks,folder_indecies(section_track_indecies),folders);

        PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
        save([saveFileName, num2str(section_index)], 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');
    end
%   end