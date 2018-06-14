%% combine watersheds to generate behavior map for forward, reverse, turns
L = combine_watersheds(L, [7,8]);
L = combine_watersheds(L, [1,2,3,4,5,6]);
behavior_names = {'Forward', 'Turns', 'Reverse'};
behavior_colors = [1,0.466666666666667,0.466666666666667; 0.854901960784314,0.00392156862745098,0.921568627450980; 0.196078431372549,0.196078431372549,1];
fps = 14;

%% get avg transition rates for all behaviors
load('reference_embedding.mat')
number_of_behaviors = max(L(:))-1;
%folders = getfoldersGUI();

relevant_track_fields = {'BehavioralTransition','Frames','Behaviors'};
Tracks = loadtracks(folders, relevant_track_fields);
alltransitions = horzcat(Tracks.Behaviors);
transition_counts = sum(alltransitions, 2);
transition_rates = transition_counts ./ size(alltransitions,2) .* fps .* 60;
transition_rates_std = sqrt(transition_counts)./size(alltransitions,2).*fps.*60;
ticklabels = behavior_names;
for behavior_index = 1:number_of_behaviors
   ticklabels{behavior_index} = [ticklabels{behavior_index},' (n=',num2str(transition_counts(behavior_index)),')'];
end
barwitherr(transition_rates_std, transition_rates)


xticklabels(ticklabels)
ylabel('Transition Rate (Transitions/worm/min)')


%% behavior tree for all transitions
degree = 3;
transition_tuples = get_behavior_tuples(number_of_behaviors, degree);
transition_tuple_counts  = zeros(1,number_of_behaviors^degree);

for track_index = 1:length(Tracks)
    behavior_sequence = Tracks(track_index).BehavioralTransition(:,1)';
    for transition_index = degree:size(Tracks(track_index).BehavioralTransition,1)
        current_tuple = behavior_sequence(transition_index-degree+1:transition_index);
        [~, tuple_index]=ismember(current_tuple,transition_tuples,'rows');
        if tuple_index > 0
            transition_tuple_counts(tuple_index) = transition_tuple_counts(tuple_index) + 1;
        end
    end
end


%% behavior tree for platetap
relevant_track_fields = {'BehavioralTransition','Frames'};
folders_platetap = getfoldersGUI();
degree = 3;
transition_tuples = get_behavior_tuples(number_of_behaviors, degree);
transition_tuple_counts  = zeros(1,number_of_behaviors^degree);


for folder_index = 1:length(folders_platetap)
    %for each experiment, search for the occurance of each stimulus after
    %normalizing to 1
    LEDVoltages = load([folders_platetap{folder_index}, filesep, 'LEDVoltages.txt']);
    % LEDVoltages = LEDVoltages(randperm(length(LEDVoltages))); %optional, randomly permuate the taps
    %LEDVoltages(LEDVoltages>0) = 1; %optional, make the stimulus on/off binary

    %find when each stimuli is played back by convolving the time
    %reversed stimulus (cross-correlation)
    xcorr_ledvoltages_stimulus = padded_conv(LEDVoltages, normalized_stimuli);
    peak_thresh = 0.99.*max(xcorr_ledvoltages_stimulus); %the peak threshold is 99% of the max (because edge effects)
    [~, tap_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

    %generate a series of control taps
    control_frame_shift = round((tap_frames(2)-tap_frames(1))/2); %the control taps are exactly in between taps
    control_LEDVoltages = circshift(LEDVoltages,[0,control_frame_shift]);
    xcorr_ledvoltages_stimulus = padded_conv(control_LEDVoltages, normalized_stimuli);
    [~, control_frames] = findpeaks(xcorr_ledvoltages_stimulus, 'MinPeakHeight', peak_thresh,'MinPeakDistance',14);

    %load the tracks for this folder
    [Tracks, ~, ~] = loadtracks(folders_platetap(folder_index),relevant_track_fields);

    %get the transitions probability for tap condition
    for track_index = 1:length(Tracks)
        behavior_sequence = Tracks(track_index).BehavioralTransition(:,1)';
        behavior_transition_frames = Tracks(track_index).Frames(Tracks(track_index).BehavioralTransition(:,2)');
        for transition_index = degree:size(Tracks(track_index).BehavioralTransition,1)
            %make sure the a event is between the first and second tuples
            transition_after_stim = false;
            for stim_index = 1:length(tap_frames)
                if behavior_transition_frames(transition_index-degree+1) <= tap_frames(stim_index) && behavior_transition_frames(transition_index-degree+2)> tap_frames(stim_index)
                    transition_after_stim = true;
                    break
                end
            end
            if transition_after_stim
                current_tuple = behavior_sequence(transition_index-degree+1:transition_index);
                [~, tuple_index]=ismember(current_tuple,transition_tuples,'rows');
                if tuple_index > 0               
                    transition_tuple_counts(tuple_index) = transition_tuple_counts(tuple_index) + 1;
                end
            end
        end
    end

    %get the transitions rates for control condition
end
