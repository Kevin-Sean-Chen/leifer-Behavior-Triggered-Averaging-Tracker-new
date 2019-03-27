%not used in paper

%calculate the triggers for LNP fitting based on velocity ranges

number_of_behaviors = 5;
%load tracks
relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Direction','Speed','Centerlines'};
folders = getfoldersGUI();
[allTracks, folder_indecies, ~] = loadtracks(folders,relevant_track_fields);
load('reference_embedding.mat')
parameters = load_parameters(folders{1});
image_size = [parameters.ImageSize parameters.ImageSize];

%% calculate the velocities, defined as the dot product between the head vector and the speed/direction vector
allTracks(1).Velocity = [];
for track_index = 1:length(allTracks)
    Track = allTracks(track_index);

    direction_vector = [[Track.Speed].*-cosd([Track.Direction]); [Track.Speed].*sind([Track.Direction])];
    head_vector = reshape(Track.Centerlines(1,:,:),2,[]) - (image_size(1)/2);    
    %normalize into unit vector
    head_normalization = hypot(head_vector(1,:), head_vector(2,:));
    head_vector = head_vector ./ repmat(head_normalization, 2, 1);
    
    allTracks(track_index).Velocity = dot(head_vector, direction_vector);
end



%% generate histogram of speeds
Velocities = [allTracks.Velocity];
velocity_ranges = min(Velocities);
for behavior_index = 1:number_of_behaviors-1
    velocity_ranges = [velocity_ranges, prctile(Velocities, behavior_index/number_of_behaviors*100)];
end
velocity_ranges = [velocity_ranges, max(Velocities)];

figure
hold on
histogram(Velocities);
for speed_range_index = 1:length(velocity_ranges)
    line([velocity_ranges(speed_range_index) velocity_ranges(speed_range_index)], [0 600000],'Color','r');
end
xlabel('Velocity (mm/s)')
ylabel('Count')


%% calculate LNP based on stereotyped speeds
%get the stereotyped behaviors based on speed
[allTracks,number_of_behaviors] = find_stereotyped_behaviors_from_velocity(allTracks);

%calculate the triggers for LNP fitting
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

[LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks,folder_indecies,folders);
PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
