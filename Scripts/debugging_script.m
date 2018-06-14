%% behavior tree for platetap
relevant_track_fields = {'BehavioralTransition','Frames'};
normalized_stimuli = 1; %delta function
%folders_platetap = getfoldersGUI();
response_cutoff = 2*fps; % how many seconds we expect stimulus driven behavior to occur

%counters
fwd = 0;
fwd_fwd = 0;
fwd_rev = 0;
fwd_turn = 0;
fwd_rev_fwd = 0;
fwd_rev_turn = 0;
fwd_turn_rev = 0;
fwd_turn_fwd = 0;
rev = 0;

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

    %tap_frames = control_frames;
    %load the tracks for this folder
    [Tracks, ~, ~] = loadtracks(folders_platetap(folder_index),relevant_track_fields);

    %get the transitions probability for tap condition
    for track_index = 1:length(Tracks)
        behavior_sequence = Tracks(track_index).BehavioralTransition(:,1)';
        behavior_transition_frames = Tracks(track_index).Frames(Tracks(track_index).BehavioralTransition(:,2)');
        for transition_index = 1:size(Tracks(track_index).BehavioralTransition,1)
            stim_transition_occured = false;
            for stim_index = 1:length(tap_frames)
                if behavior_transition_frames(transition_index) <= tap_frames(stim_index) 
                    if transition_index == size(Tracks(track_index).BehavioralTransition,1)
                        % stim occured, last behavior
                        if Tracks(track_index).Frames(end) > tap_frames(stim_index) + response_cutoff
                            stim_transition_occured = false;
                            if behavior_sequence(transition_index) == 1
                                %fwd = fwd + 1;
                            end
                        end
                    elseif behavior_transition_frames(transition_index+1) > tap_frames(stim_index)
                        % stim occured, transisition
                        stim_transition_occured = true;
                        break
                    end
                end
            end
            if stim_transition_occured && behavior_sequence(transition_index) == 1
                % only count while going forward
                fwd = fwd + 1;
                if behavior_transition_frames(transition_index+1) - tap_frames(stim_index) > response_cutoff
                    %if within 2s no behavior change
                    fwd_fwd = fwd_fwd + 1;
                elseif behavior_sequence(transition_index+1) == 3
                    %if within 2s rev
                    fwd_rev = fwd_rev + 1;
                    if transition_index+2 <= length(behavior_sequence)
                       %one more transition occurs after
                       if behavior_sequence(transition_index+2) == 1
                           fwd_rev_fwd = fwd_rev_fwd + 1;
                       elseif behavior_sequence(transition_index+2) == 2
                           fwd_rev_turn = fwd_rev_turn + 1;
                       end
                    end
                elseif behavior_sequence(transition_index+1) == 2
                    fwd_turn = fwd_turn + 1; 
                end
            elseif stim_transition_occured && behavior_sequence(transition_index) == 2
                rev = rev + 1;
            end
        end
    end

end

% set up output for sankey plot

% only look at forward:
