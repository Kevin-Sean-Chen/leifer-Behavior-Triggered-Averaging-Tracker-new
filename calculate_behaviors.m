function success = calculate_behaviors(folder_name)
% use behavioral mapping to analyze a group of experiments
    addpath(genpath(pwd))
    %set up parameters
    parameters = load_parameters(folder_name);
    load('reference_embedding.mat')
    number_of_behaviors = max(L(:)-1);
    relevant_track_fields = {'Spectra'};

    %% Load tracks
    Tracks = load_single_folder(folder_name, relevant_track_fields);
    if isempty(Tracks)
        error('Empty Tracks');
    end

    try
        parpool(feature('numcores'))
    catch
        %sometimes matlab attempts to write to the same temp file. wait and
        %restart
        pause(20);
        parpool(feature('numcores'))
    end


    data = vertcat(Tracks.Spectra);
    [embeddingValues,~] = findEmbeddings(data,trainingSetData,trainingEmbedding,parameters);
    clear data

    % cut the embeddings
    Tracks(1).Embeddings = []; %preallocate memory
    Tracks(1).Spectra = [];  %preallocate memory
    Tracks(1).Amps = [];
    start_index = 1;
    for track_index = 1:length(Tracks)
        end_index = start_index + size(Tracks(track_index).Spectra,1) - 1;
        Tracks(track_index).Embeddings = embeddingValues(start_index:end_index, :);
        start_index = end_index + 1;
    end

    %get the stereotyped behaviors
    Tracks = find_stereotyped_behaviors(Tracks, L, xx);

    % Get binary array of when certain behaviors start
    Tracks(1).Behaviors = [];

    for track_index = 1:length(Tracks)
        triggers = false(number_of_behaviors, length(Tracks(track_index).Frames)); %a binary array of when behaviors occur
        for behavior_index = 1:number_of_behaviors
            transition_indecies = Tracks(track_index).BehavioralTransition(:,1) == behavior_index;
            %transition into of
            transition_start_frames = Tracks(track_index).BehavioralTransition(transition_indecies,2);
            triggers(behavior_index,transition_start_frames) = true;
%                 %transition out of
%                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
%                 triggers(behavior_index,transition_end_frames) = true;
        end
        Tracks(track_index).Behaviors = triggers(:,1:length(Tracks(track_index).Frames));
    end

    %save
    savetracks(Tracks, folder_name);
    success = true;    
 end