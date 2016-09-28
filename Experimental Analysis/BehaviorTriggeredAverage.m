function [BTA, behaviorCounts] = BehaviorTriggeredAverage(Behaviors, LEDPowers)
    %finds the behavior triggered average
    fps = 14;
    BTA_seconds_before_and_after = 10;

    seconds_before = BTA_seconds_before_and_after;
    seconds_after = BTA_seconds_before_and_after;
  
    number_of_behaviors = size(Behaviors{1},1);
    behaviorCounts = zeros(number_of_behaviors,1);
    BTA = zeros(number_of_behaviors,(fps*seconds_before)+(fps*seconds_after)+1);

    parfor behavior_index = 1:number_of_behaviors
        tracksCentered = [];
        for track_index = 1:length(Behaviors)
            %get a BTA for each trigger
            triggers = find(Behaviors{track_index}(behavior_index,:));
            for trigger_index = 1:length(triggers)
                current_trigger = triggers(trigger_index);
                LEDPower = LEDPowers{track_index};
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
        disp(num2str(behavior_index))
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
