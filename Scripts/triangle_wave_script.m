folders = getfoldersGUI();
[allTracks, folder_indecies, track_indecies ] = loadtracks(folders,{'BehavioralTransition',...
    'Path','Frames','LEDPower','LEDVoltages','Behaviors','Embeddings'});

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

%% cut up tracks into uptick frames and downtick frames
%get what the triangle wave looks like
LEDVoltages = load([folders{1}, filesep, 'LEDVoltages.txt']);
second_deriv = [0, diff(diff(LEDVoltages)), 0];
uptick_starts = [1, find(second_deriv > 0.01)];
uptick_ends = [find(second_deriv < -0.01), length(LEDVoltages)];
all_uptick_tracks = [];
all_uptick_track_indecies = [];
for section_index = 1:length(uptick_starts)
    start_frame = uptick_starts(section_index)+1;
    end_frame = uptick_ends(section_index);

    [temp_tracks, temp_track_indecies] = FilterTracksByTime(newallTracks,start_frame,end_frame);
    all_uptick_tracks = [all_uptick_tracks, temp_tracks];
    all_uptick_track_indecies = [all_uptick_track_indecies, temp_track_indecies];
end

downtick_starts = find(second_deriv < -0.01);
downtick_ends = [find(second_deriv > 0.01), length(LEDVoltages)];
all_downtick_tracks = [];
all_downtick_track_indecies = [];
for section_index = 1:length(uptick_starts)
    start_frame = downtick_starts(section_index)+1;
    end_frame = downtick_ends(section_index);

    [temp_tracks, temp_track_indecies] = FilterTracksByTime(newallTracks,start_frame,end_frame);
    all_downtick_tracks = [all_downtick_tracks, temp_tracks];
    all_downtick_track_indecies = [all_downtick_track_indecies, temp_track_indecies];
end

uptick_behaviors = [all_uptick_tracks.Behaviors];
downtick_behaviors = [all_downtick_tracks.Behaviors];

uptick_behavioral_counts = sum(uptick_behaviors,2);
downtick_behavioral_counts = sum(downtick_behaviors,2);

uptick_behavioral_std = sqrt(uptick_behavioral_counts) ./ size(uptick_behaviors,2)*14*60;
downtick_behavioral_std = sqrt(downtick_behavioral_counts) ./ size(downtick_behaviors,2)*14*60;

uptick_behavioral_rates = uptick_behavioral_counts ./ size(uptick_behaviors,2)*14*60;
downtick_behavioral_rates = downtick_behavioral_counts ./ size(downtick_behaviors,2)*14*60;


figure
hold on
errorbar(uptick_behavioral_rates, uptick_behavioral_std, 'r*')
errorbar(downtick_behavioral_rates, downtick_behavioral_std, 'bo')
hold off 
xlabel('Behavioral Region');
ylabel('Transition Rate (Behavior/Min)');
legend({'Increasing','Decreasing'});
%% plot the LEDPower
fps = 14;
parameters = load_parameters();
LEDPower = LEDVoltages .* parameters.avgPower500 ./ 5;
plot(1/fps:1/fps:length(LEDVoltages)/fps, LEDPower)
xlabel('Time (s)')
ylabel('Power (uW/mm^2)')
%% plot embedding densities
