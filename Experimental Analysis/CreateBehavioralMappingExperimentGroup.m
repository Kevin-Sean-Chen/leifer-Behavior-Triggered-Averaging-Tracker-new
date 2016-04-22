% analyzes a group of experiments and saves the properties
% they will be saved inside the first folder
function Experiments = CreateBehavioralMappingExperimentGroup()
    %clear all;
    %set up parameters
    parameters.numProcessors = 15;
    parameters.numProjections = 19;
    parameters.pcaModes = 5;
    parameters.samplingFreq = 14;
    parameters.minF = 0.3;
    parameters.maxF = parameters.samplingFreq ./ 2; %nyquist frequency
    parameters.trainingSetSize = 50000;
    parameters.subsamplingIterations = 10;
    parameters = setRunParameters(parameters);
    Prefs = load_excel_prefs;
    fps = 14;
    behavior_watershed_index = 9;
    load('reference_embedding.mat')
    
    folders = {};
    Experiments = [];
    
    [filename,pathname] = uiputfile('*.mat','Save Experiment Group As');
    
    if isequal(filename,0) || isequal(pathname,0)
        %cancel
       return
    else
        saveFileName = fullfile(pathname,filename);
        if exist(saveFileName, 'file')
          % File exists.  Load the folders
          previously_loaded_experiments = load(saveFileName);
          folders = {previously_loaded_experiments.Experiments(1:end-1).Folder};
          Experiments = [];
          for i = 1:length(folders)
              Experiments(i).Folder = folders{i};
          end
        else
          % File does not exist. Ask for experiment folders
            while true
                if isempty(folders)
                    start_path = pathname;
                else
                    start_path = fileparts(fullfile(folders{length(folders)}, '..', filename)); %display the parent folder
                end
                folder_name = uigetdir(start_path, 'Select Experiment Folder')
                if folder_name == 0
                    break
                else
                    folders{length(folders)+1} = folder_name;
                    Experiments(length(folders)).Folder = folder_name;
                end
            end
        end
    end
    allTracks = struct([]);
    Experiments(length(folders)+1).Folder = [];

    for folder_index = 1:length(folders)+1
        if folder_index <= length(folders)
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
            
            if ~isfield(Tracks, 'BehavioralTransition')
                %get the spectra
                [Spectra, ~, ~, ~] = generate_spectra(Tracks, parameters, Prefs);

                data = vertcat(Spectra{:});
                amps = sum(data,2);
                data(:) = bsxfun(@rdivide,data,amps);
                [embeddingValues,~] = findEmbeddings(data,trainingSetData,trainingEmbedding,parameters);
                clear data

                % cut the embeddings
                Tracks(1).Embeddings = []; %preallocate memory
                start_index = 1;
                training_start_index = 1;
                for track_index = 1:length(Spectra)
                    end_index = start_index + size(Spectra{track_index},1) - 1;
                    Tracks(track_index).Embeddings = embeddingValues(start_index:end_index, :);
                    start_index = end_index + 1;
                end

                %get the stereotyped behaviors
                Tracks = find_stereotyped_behaviors(Tracks, L, xx);

                %autosave
                saveFileName = [folder_name '\tracks.mat'];
                save(saveFileName, 'Tracks');
                AutoSave(folder_name, Prefs.DefaultPath);
            end
            
            % Get binary array of when certain behaviors start
            Tracks(1).Behaviors = [];
            for track_index = 1:length(Tracks)
                triggers = false(1, length(Tracks(track_index).LEDVoltages)); %a binary array of when behaviors occur
                transition_indecies = Tracks(track_index).BehavioralTransition(:,1) == behavior_watershed_index;
                transition_start_frames = Tracks(track_index).BehavioralTransition(transition_indecies,2);
                triggers(transition_start_frames) = true;
                Tracks(track_index).Behaviors = triggers;
            end
            
            if length(allTracks) == 0
                allTracks = Tracks;
            else
                allTracks = [allTracks, Tracks];
            end

            %fit the LNP
            [Experiments(folder_index).linear_kernel, Experiments(folder_index).non_linearity_fit, Experiments(folder_index).BTA, Experiments(folder_index).meanLEDVoltage, Experiments(folder_index).pirouetteCount, Experiments(folder_index).bin_edges, Experiments(folder_index).filtered_signal_histogram, Experiments(folder_index).filtered_signal_given_reversal_histogram] = FitLNP(Tracks);
            %get speed
            [Experiments(folder_index).Speed, Experiments(folder_index).speed_sum, Experiments(folder_index).frame_count] = SpeedHistogram([],fps*60,Tracks,frames);
            %get reversal rate
            [Experiments(folder_index).ReversalRate, Experiments(folder_index).ReversalCounts, Experiments(folder_index).FrameCounts] = ReversalRate([],fps*60,Tracks,frames);
            %save LEDVoltages
            Experiments(folder_index).LEDVoltages = LEDVoltages;
            %find the filtered signal (not used in LNP fitting)
            filtered_signal = conv(Experiments(folder_index).LEDVoltages, Experiments(folder_index).linear_kernel);
            Experiments(folder_index).FilteredSignal = filtered_signal(1:length(Experiments(folder_index).LEDVoltages)); %cut off the tail
        else
            %the very last entry in Experiments is the average of all experiments
            %fit the LNP
            [Experiments(folder_index).linear_kernel, Experiments(folder_index).non_linearity_fit, Experiments(folder_index).BTA, Experiments(folder_index).meanLEDVoltage, Experiments(folder_index).pirouetteCount, Experiments(folder_index).bin_edges, Experiments(folder_index).filtered_signal_histogram, Experiments(folder_index).filtered_signal_given_reversal_histogram] = FitLNP(allTracks);
            %get speed
            [Experiments(folder_index).Speed, Experiments(folder_index).speed_sum, Experiments(folder_index).frame_count] = SpeedHistogram([],fps*60,allTracks,frames);
            %the average case, concatenate all the behaviors
            [Experiments(folder_index).ReversalRate, Experiments(folder_index).ReversalCounts, Experiments(folder_index).FrameCounts] = ReversalRate([],fps*60,allTracks,frames);
            %save LEDVoltages
            Experiments(folder_index).LEDVoltages = [Experiments.LEDVoltages];
            %the average case, concatenate all the filtered signals found
            %before
            Experiments(folder_index).FilteredSignal = [Experiments.FilteredSignal];
        end
    end
    PlotExperimentGroup(Experiments);
    save(saveFileName, 'Experiments');

 end