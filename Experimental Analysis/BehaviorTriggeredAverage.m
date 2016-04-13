
function [BTA, behaviorCount] = BehaviorTriggeredAverage(folders, allTracks)
    fps = 14;
    seconds_before = 10;
    seconds_after = 10;
    numbins = 10;
        
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
    
    if nargin < 2 %if only tracks are given
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
    
   
    tracksCentered = [];
    behaviorCount = 0;

    for track_index = 1:length(allTracks)
        if isfield(allTracks, 'Behaviors')
            triggers = find(allTracks(track_index).Behaviors);
            for trigger_index = 1:length(triggers)
                current_trigger = triggers(trigger_index);
                LEDVoltages = allTracks(track_index).LEDVoltages;
                if current_trigger - (fps*seconds_before) < 1 || current_trigger + (fps*seconds_after) > length(LEDVoltages)
                    %pad voltages with 0s if needed, but otherwise just ignore it
                else
                    tracksCentered = cat(1, tracksCentered, LEDVoltages(:, current_trigger-(fps*seconds_before):current_trigger+(fps*seconds_after)));
                    behaviorCount = behaviorCount + 1;
                end
            end
        else
            
        end
    end

    BTA = mean(tracksCentered,1);
    %BTA = [0, mean(diff(tracksCentered,1,2),1)];
    if nargin < 1
        %plot(-seconds_before:1/fps:seconds_after, mean(diff(tracksCentered,1)))
        %figure
        shadedErrorBar(-seconds_before:1/fps:seconds_after, BTA, 2/sqrt(behaviorCount)*ones(1,length(BTA)));
        %plot(-seconds_before:1/fps:seconds_after, mean(tracksCentered,1))
        %legend(num2str(tracksByVoltage(voltage_index).voltage));
        xlabel(strcat('second (', num2str(behaviorCount), ' behaviors analyzed)')) % x-axis label
        ylabel('voltage') % y-axis label
        %axis([-10 2 0.64 0.84])
    end
    %load('LEDVoltages.txt')

    % figure
    % plot(0:1/fps:(size(LEDVoltages,2)-1)/fps, LEDVoltages)
    % xlabel(strcat('time (s)')) % x-axis label
    % ylabel('voltage') % y-axis label
end
