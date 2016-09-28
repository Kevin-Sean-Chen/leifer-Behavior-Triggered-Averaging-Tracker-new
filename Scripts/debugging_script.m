load('embedding_symmetrci_GWN_16_09_18.mat')
load('mec4_noret_tracks.mat')
noretTracks = allTracks;
load('mec4_ret_tracks.mat')
allTracks = [allTracks,noretTracks];
clear noretTracks

Embeddings = [];
for folder_index = 1:length(folders)
    %single experiment
    folder_name = folders{folder_index}
    load([folder_name '\embeddings.mat'])
    Embeddings = [Embeddings; embeddingValues];
end

embeddingValues = Embeddings;

Embeddings = cell(1,length(allTracks));

start_index = 1;
for track_index = 1:length(allTracks)
    end_index = start_index + length(allTracks(track_index).Frames) - 1;
    Embeddings{track_index} = embeddingValues(start_index:end_index, :);
    start_index = end_index + 1;
end

folder_indecies = [];
track_indecies = [];
for folder_index = 1:length(folders)
    curDir = [folders{folder_index} '\individual_worm_imgs'];
    indiviudal_image_files=dir([curDir, '\*.mat']);
    if isempty(indiviudal_image_files)
        curDir
    end
    folder_indecies = [folder_indecies, repmat(folder_index,1,length(indiviudal_image_files))];
    track_indecies = [track_indecies, 1:length(indiviudal_image_files)];
end


allTracks(1).Embeddings = []; %preallocate memory
start_index = 1;
for track_index = 1:length(allTracks)
    allTracks(track_index).Embeddings = Embeddings{track_index};
end

%get the stereotyped behaviors
allTracks = find_stereotyped_behaviors(allTracks, L, xx);

number_of_behaviors = max(L(:)-1);
allTracks(1).Behaviors = [];
for track_index = 1:length(allTracks)
    triggers = false(number_of_behaviors, length(allTracks(track_index).LEDVoltages)); %a binary array of when behaviors occur
    for behavior_index = 1:number_of_behaviors
        transition_indecies = allTracks(track_index).BehavioralTransition(:,1) == behavior_index;
        %transition into of
        transition_start_frames = allTracks(track_index).BehavioralTransition(transition_indecies,2);
        triggers(behavior_index,transition_start_frames) = true;
%                 %transition out of
%                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
%                 triggers(behavior_index,transition_end_frames) = true;
    end
    allTracks(track_index).Behaviors = triggers(:,1:length(allTracks(track_index).LEDVoltages));
end

[LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks(1:end-19995),folder_indecies(1:end-19995),folders);
PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
save('16_09_20_embedding_ret_LNPFit_nonlinearityfix.mat', 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');

[LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks(length(allTracks)-19994:end),folder_indecies(length(allTracks)-19994:end),folders);
PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
save('16_09_20_embedding_noret_LNPFit_nonlinearityfix.mat', 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');


max_frame_number = 30*60*parameters.samplingFreq;
number_of_sections = 3;
saveFileName = '16_09_20_embedding_ret_LNPFit_NLfix_section_';
for section_index = 1:number_of_sections
    start_frame = (section_index-1)*max_frame_number/number_of_sections+1;
    end_frame = section_index*max_frame_number/number_of_sections;

    [section_Tracks, section_track_indecies] = FilterTracksByTime(allTracks,start_frame,end_frame);
    [LNPStats, meanLEDPower, stdLEDPower] = FitLNP(section_Tracks,folder_indecies(section_track_indecies),folders);

    PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
    save([saveFileName, num2str(section_index), '.mat'], 'folders', 'LNPStats', 'L', 'density', 'xx', 'meanLEDPower', 'stdLEDPower');
end
