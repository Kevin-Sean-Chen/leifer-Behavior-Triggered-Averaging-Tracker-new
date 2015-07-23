
function [BTA, behaviorCount] = BehaviorTriggeredAverage(folders, allTracks, behavior)
    fps = 14;
    seconds_before = 10;
    seconds_after = 1;
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
    
    if nargin < 3 %no behavior is given
        behavior = 'reversal_start';
    end
    
    tracksCentered = [];
    behaviorCount = 0;

    for track = 1:length(allTracks)
        if strcmp(behavior, 'reversal_start')
            pirouettes = allTracks(track).Pirouettes;
            for pirouette_index = 1:size(pirouettes,1)
                pirouetteStart = pirouettes(pirouette_index,1);
                LEDVoltages = allTracks(track).LEDVoltages;
                if pirouetteStart - (fps*seconds_before) < 1 || pirouetteStart + (fps*seconds_after) > length(LEDVoltages)
                    %pad voltages with 0s if needed, but otherwise just ignore it
                else
                    tracksCentered = cat(1, tracksCentered, LEDVoltages(:, pirouetteStart-(fps*seconds_before):pirouetteStart+(fps*seconds_after)));
                    behaviorCount = behaviorCount + 1;
                end
            end
        elseif strcmp(behavior, 'omega_turn_start')
            OmegaTurns = allTracks(track).OmegaTurns;
            for omega_turn_index = 1:size(OmegaTurns,1)
                OmegaTurnStart = OmegaTurns(omega_turn_index,1);
                LEDVoltages = allTracks(track).LEDVoltages;
                if OmegaTurnStart - (fps*seconds_before) < 1 || OmegaTurnStart + (fps*seconds_after) > length(LEDVoltages)
                    %pad voltages with 0s if needed, but otherwise just ignore it
                else
                    tracksCentered = cat(1, tracksCentered, LEDVoltages(:, OmegaTurnStart-(fps*seconds_before):OmegaTurnStart+(fps*seconds_after)));
                    behaviorCount = behaviorCount + 1;
                end
            end
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
