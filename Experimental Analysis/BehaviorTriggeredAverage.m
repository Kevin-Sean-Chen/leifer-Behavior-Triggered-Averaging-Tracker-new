function [BTA, behaviorCounts] = BehaviorTriggeredAverage(folders, allTracks)
    %finds the behavior triggered average
    fps = 14;
    seconds_before = 10;
    seconds_after = 10;
        
    if nargin < 1 %no folders are given, ask user to select
        folders = {};
        while true
            folder_name = uigetdir
            if folder_name == 0
                break
            else
                folders{length(folders)+1} = folder_name;
            end
        end
    end
    
    if nargin < 2 %if no tracks are given
        allTracks = struct([]);
        for folder_index = 1:length(folders)
            folder_name = folders{folder_index};
            cd(folder_name) %open the directory of image sequence
            load('tracks.mat')
            if length(allTracks) == 0
                allTracks = Tracks;
            else
                allTracks = [allTracks, Tracks];
            end  
        end
    end
    
    number_of_behaviors = size(allTracks(1).Behaviors,1);
    behaviorCounts = zeros(number_of_behaviors,1);
    BTA = zeros(number_of_behaviors,(fps*seconds_before)+(fps*seconds_after)+1);

    if isfield(allTracks, 'Behaviors')
    else
        %does not support tracks without behaviors
        return
    end

    for behavior_index = 1:number_of_behaviors
        tracksCentered = [];
        for track_index = 1:length(allTracks)
            %get a BTA for each trigger
            triggers = find(allTracks(track_index).Behaviors(behavior_index,:));
            for trigger_index = 1:length(triggers)
                current_trigger = triggers(trigger_index);
                LEDPower = allTracks(track_index).LEDPower;
%                 LEDPower = allTracks(track_index).LEDVoltages;
                if current_trigger - (fps*seconds_before) < 1 || current_trigger + (fps*seconds_after) > length(LEDPower)
                    %pad voltages with 0s if needed, but otherwise just ignore it
                else
                    tracksCentered = cat(1, tracksCentered, LEDPower(:, current_trigger-(fps*seconds_before):current_trigger+(fps*seconds_after)));
                    behaviorCounts(behavior_index) = behaviorCounts(behavior_index) + 1;
                end
            end
        end
        if ~isempty(tracksCentered)
            BTA(behavior_index,:) = mean(tracksCentered,1);
        end
    end

    
    %BTA = [0, mean(diff(tracksCentered,1,2),1)];
    if nargin < 1
        %plot(-seconds_before:1/fps:seconds_after, mean(diff(tracksCentered,1)))
        %figure
        shadedErrorBar(-seconds_before:1/fps:seconds_after, BTA, 2/sqrt(behaviorCounts)*ones(1,length(BTA)));
        %plot(-seconds_before:1/fps:seconds_after, mean(tracksCentered,1))
        %legend(num2str(tracksByVoltage(voltage_index).voltage));
        xlabel(strcat('second (', num2str(behaviorCounts), ' behaviors analyzed)')) % x-axis label
        ylabel('voltage') % y-axis label
        %axis([-10 2 0.64 0.84])
    end
    %load('LEDVoltages.txt')

    % figure
    % plot(0:1/fps:(size(LEDVoltages,2)-1)/fps, LEDVoltages)
    % xlabel(strcat('time (s)')) % x-axis label
    % ylabel('voltage') % y-axis label
end
