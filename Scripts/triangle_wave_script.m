folders = getfoldersGUI();
[allTracks, folder_indecies, track_indecies ] = loadtracks(folders);

%calculate the triggers for LNP fitting
number_of_behaviors = max(L(:)-1);
allTracks(1).Behaviors = [];
for track_index = 1:length(allTracks)
    triggers = false(number_of_behaviors, length(allTracks(track_index).Frames)); %a binary array of when behaviors occur
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

[TestLNPStats] = ValidateLNP(allTracks, folder_indecies, folders, LNPStats);
PlotValidateBehavioralMappingExperimentGroup(TestLNPStats, LNPStats, meanLEDPower, stdLEDPower, L, density, xx);

%% cut up tracks into 10 min sections and compare to LNP params
max_frame_number = 30*60*14;
number_of_sections = 3;
loadFileName = '16_09_20_embedding_ret_LNPFit_NLfix_12_behaviors_section_';
for section_index = 1:number_of_sections
    load([loadFileName, num2str(section_index), '.mat']);
    
    start_frame = (section_index-1)*max_frame_number/number_of_sections+1;
    end_frame = section_index*max_frame_number/number_of_sections;

    [section_Tracks, section_track_indecies] = FilterTracksByTime(allTracks,start_frame,end_frame);
    [TestLNPStats] =  ValidateLNP(section_Tracks,folder_indecies(section_track_indecies),folders,LNPStats);

    PlotValidateBehavioralMappingExperimentGroup(TestLNPStats, LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
end
