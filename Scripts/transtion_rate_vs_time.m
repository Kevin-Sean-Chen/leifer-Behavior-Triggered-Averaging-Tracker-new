load('reference_embedding.mat')
%load tracks
% relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};
relevant_track_fields = {'BehavioralTransition','Frames'};
number_of_behaviors = max(L(:)-1);
fps = 14;


%select folders, load tracks
folders = getfoldersGUI();
[allTracks, ~, ~] = loadtracks(folders,relevant_track_fields);
allTracks = BehavioralTransitionToBehavioralAnnotation(allTracks);
allTracks = get_behavior_triggers(allTracks);

maxframe = max(horzcat(allTracks.Frames));

behavior_counts_for_frame = zeros(number_of_behaviors,maxframe);
behavior_transition_counts_for_frame = zeros(number_of_behaviors,maxframe);
behavior_ratios_for_frame = zeros(number_of_behaviors,maxframe);
total_counts_for_frame = zeros(1,maxframe);

for frame_index = 1:maxframe
    tracks_on_critical_frame = FilterTracksByTime(allTracks, frame_index, frame_index);
    behavior_annotations_for_frame = [tracks_on_critical_frame.BehavioralAnnotation];
    behavior_transitions_for_frame = [tracks_on_critical_frame.Behaviors];
    for behavior_index = 1:number_of_behaviors
        behavior_counts_for_frame(behavior_index, frame_index) = sum(behavior_annotations_for_frame == behavior_index);
    end
    behavior_transition_counts_for_frame(:, frame_index) = sum(behavior_transitions_for_frame,2);
    total_counts_for_frame(frame_index) = length(tracks_on_critical_frame);
    behavior_ratios_for_frame(:,frame_index) = behavior_counts_for_frame(:,frame_index)./total_counts_for_frame(frame_index); %get ratio
end
transition_rate_for_frame = behavior_transition_counts_for_frame ./ repmat(total_counts_for_frame,number_of_behaviors,1) .*fps.*60;

%track_n = round(mean(arrayfun(@(x) size(x{1},2), behaviors_for_frame)));
my_colors = behavior_colors;
figure
hold on
for behavior_index = 1:number_of_behaviors
    plot(1/fps/60:1/fps/60:length(behavior_ratios_for_frame)/fps/60, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
end
hold off
%title(['(n = ', num2str(track_n), ' tracks)']);
xlabel('Time (min)') % x-axis label
ylabel('Behavioral Ratio') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

        
observed_moving_average_transition_rate = movingmean(transition_rate_for_frame, 28, 2);

figure
hold on
for behavior_index = 8:8
    plot(1/fps/60:1/fps/60:length(transition_rate_for_frame)/fps/60, transition_rate_for_frame(behavior_index,:), '-', 'color', [my_colors(behavior_index,:) 0.025],'Linewidth', 2,'DisplayName',behavior_names{behavior_index});
    %plot the moving average transition rate in behavior color solid line
    plot(1/fps/60:1/fps/60:length(transition_rate_for_frame)/fps/60, observed_moving_average_transition_rate(behavior_index,:), '-', 'color', my_colors(behavior_index,:) ,'Linewidth', 4,'DisplayName',[behavior_names{behavior_index}, ' 2s moving average']);
end
hold off
%title(['(n = ', num2str(track_n), ' tracks)']);
xlabel('Time (min)') % x-axis label
ylabel('Transition rate (transitions/min)') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

