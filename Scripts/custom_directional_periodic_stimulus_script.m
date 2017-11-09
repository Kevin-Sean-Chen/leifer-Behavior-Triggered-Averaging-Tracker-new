auto_stimulus_period = true; %stimulus_period is found by autocorrelation if this is true
binarize_stimulus = false;
stimulus_period = 60*14-1; 
starting_shift = 0;
relevant_track_fields = {'BehavioralTransition','Frames'};

load('reference_embedding.mat')
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit.mat')

LNPStats = LNPStats_directional_ret;

%select folders
folders = getfoldersGUI();

fps = 14;

number_of_edges = length(LNPStats);
stimulus_templates = [];
all_behavior_transitions_for_frame = {};
predicted_behavior_transitions_for_stim = {};

%% behavioral rate compare
for folder_index = 1:length(folders)
    %load the tracks for this folder
    [current_tracks, folder_indecies_revstim_ret, track_indecies_revstim_ret] = loadtracks(folders{folder_index},relevant_track_fields);
    current_tracks = BehavioralTransitionToBehavioralAnnotation(current_tracks);
    %generate the Behavior matricies
    current_tracks = get_directional_behavior_triggers(current_tracks);

    current_param = load_parameters(folders{folder_index});
    LEDVoltages = load([folders{folder_index}, filesep, 'LEDVoltages.txt']);
    
    %convert LEDVoltages to power
    LEDPowers = LEDVoltages .* current_param.avgPower500 ./ 5;

    if binarize_stimulus
        % anything different from the baseline we will treat as a stimulus
        % delivery
        baseline_indecies = LEDPowers == mode(LEDPowers);
        LEDPowers_for_finding_stimulus = ones(1,length(LEDPowers));
        LEDPowers_for_finding_stimulus(baseline_indecies) = 0;
    else
        %round it
        LEDPowers_for_finding_stimulus = LEDPowers;
    end
    
    experiment_behavior_predictions = zeros(number_of_edges,length(LEDPowers));
    %predict the behavioral rates based on the preloaded LNP model
    for transition_index = 1:number_of_edges
        experiment_behavior_predictions(transition_index,:) = PredictLNP(LEDPowers, LNPStats(transition_index).linear_kernel, LNPStats(transition_index).non_linearity_fit);
    end

    %cut the powers into chunks with the characteristic period
    if auto_stimulus_period
        %get the stimulus_period
        [stimulus_peak_intensities,stimulus_peaks] = findpeaks(LEDPowers_for_finding_stimulus, 'minpeakdistance', 10*fps);
        stimulus_period = mode(diff(stimulus_peaks));
        
        %we also need to find the shift needed because we want to center
        %the stimulus in the middle of our time frame
        peak_index = 1;
        while peak_index>0
            starting_shift = stimulus_peaks(peak_index) - floor(stimulus_period/2);
            if starting_shift > 0
                peak_index = 0;
            end
        end
        %do this only once assuming all our experiments are alike
        auto_stimulus_period = false;
    else
        %the stimulus_period is predefined. use that
    end

    number_of_trials = floor((length(LEDPowers)-starting_shift)/stimulus_period);
    LEDPowers_reshaped_by_trial = reshape(LEDPowers(starting_shift+1:stimulus_period*number_of_trials+starting_shift),stimulus_period,number_of_trials);
    
    %loop through the peaks and cut up tracks
    for trial_index = 1:number_of_trials
        %get the current stimulus
        current_stim = LEDPowers_reshaped_by_trial(:,trial_index)';
        %see if this stim_power already exists
        current_stim_index = is_approximate_member(current_stim,stimulus_templates);
        if current_stim_index == 0;
            %no entry yet
            stimulus_templates = [stimulus_templates;current_stim];
            current_stim_index = size(stimulus_templates,1);
            all_behavior_transitions_for_frame{current_stim_index} = cell(1,stimulus_period);
        end
        
        %for every time a stimulus is delivered, look at a certain range of
        %frames
        for frame_shift = 1:stimulus_period
            current_frame = ((trial_index-1)*stimulus_period) + frame_shift + starting_shift;
            if current_frame <= length(LEDPowers) && current_frame >= 1
                %make sure the current frame is in range
                tracks_on_critical_frame = FilterTracksByTime(current_tracks,current_frame, current_frame);
                if ~isempty(tracks_on_critical_frame)
                    all_behavior_transitions_for_frame{current_stim_index}{frame_shift} = [all_behavior_transitions_for_frame{current_stim_index}{frame_shift}, tracks_on_critical_frame.Behaviors];
                end
            end
        end
        %overwrite the last predicted behavioral response with this one, can replace with some sort of average if we want later
        predicted_behavior_transitions_for_stim{current_stim_index} = experiment_behavior_predictions(:,((trial_index-1)*stimulus_period)+starting_shift+1:trial_index*stimulus_period+starting_shift);
    end
end

%%sort the stimulus intensities
%[stimulus_templates, sort_index] = sort(stimulus_templates);
%all_behavior_transitions_for_frame = all_behavior_transitions_for_frame(sort_index);

number_of_stimulus_templates = size(stimulus_templates,1);

%% 1 plot the transition rates as a function of time
for stimulus_index = 1:number_of_stimulus_templates
    % plot the transition rates for each stimulus template
    transition_rate_for_frame = zeros(number_of_edges,stimulus_period);
    transition_std_for_frame = zeros(number_of_edges,stimulus_period);
    for frame_index = 1:stimulus_period
        transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
        transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
        transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
    end
    
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    my_colors = lines(number_of_edges);
    figure
    hold on
    for transition_index = 1:number_of_edges
        plot(1/fps:1/fps:stimulus_period/fps, transition_rate_for_frame(transition_index,:), '-', 'color', my_colors(transition_index,:),'Linewidth', 3,'DisplayName',[num2str(LNPStats(transition_index).Edges(1)), 'to', num2str(LNPStats(transition_index).Edges(2))]);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('Transition Rate (transitions/min)') % y-axis label
    title(['Stimulus Index = ', num2str(stimulus_index), ' (n = ', num2str(track_n), ')']);
    legend('show');
    ax = gca;
    ax.FontSize = 10;
end

%% plot the predicted and actual behavior rates in the same graph
for stimulus_index = 1:number_of_stimulus_templates
    transition_rate_for_frame = zeros(number_of_edges,stimulus_period);
    transition_std_for_frame = zeros(number_of_edges,stimulus_period);
    for frame_index = 1:stimulus_period
        transitions_for_frame = all_behavior_transitions_for_frame{stimulus_index}{frame_index};
        transition_rate_for_frame(:,frame_index) = sum(transitions_for_frame,2)./size(transitions_for_frame,2).*fps.*60;
        transition_std_for_frame(:,frame_index) = sqrt(sum(transitions_for_frame,2))./size(transitions_for_frame,2).*fps.*60;
    end
    
    track_n = round(mean(arrayfun(@(x) size(x{1},2), [all_behavior_transitions_for_frame{stimulus_index}])));
    my_colors = lines(number_of_edges);
    figure
    hold on
    for transition_index = 1:number_of_edges
        plot(1/fps:1/fps:stimulus_period/fps, transition_rate_for_frame(transition_index,:) - mean(transition_rate_for_frame(transition_index,:)) + double(transition_index), '-', 'color', [my_colors(transition_index,:), 0.5],'Linewidth', 3,'DisplayName',[num2str(LNPStats(transition_index).Edges(1)), 'to', num2str(LNPStats(transition_index).Edges(2)), 'actual']);
        plot(1/fps:1/fps:stimulus_period/fps, predicted_behavior_transitions_for_stim{stimulus_index}(transition_index,:) - mean(predicted_behavior_transitions_for_stim{stimulus_index}(transition_index,:)) + double(transition_index), '-', 'color', my_colors(transition_index,:),'Linewidth', 2,'DisplayName',[num2str(LNPStats(transition_index).Edges(1)), 'to', num2str(LNPStats(transition_index).Edges(2)), ' predicted']);
    end
    hold off
    xlabel('Time (s)') % x-axis label
    ylabel('LNP Preidcted Transition Rate (transitions/min)') % y-axis label
    title(['Stimulus Index = ', num2str(stimulus_index), ' (n = ', num2str(track_n), ')']);

    legend('show');
    ax = gca;
    ax.FontSize = 10;
end
