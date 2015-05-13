peak_voltage = 2;
linear_filter_stimulus = BTAFilter();
factor = peak_voltage / max(linear_filter_stimulus);
linear_filter_stimulus = linear_filter_stimulus * factor;
intensity_sum = sum(linear_filter_stimulus);
square_pulse_stimulus = SquarePulse(intensity_sum, length(linear_filter_stimulus));
triangle_pulse_stimulus = TrianglePulse(intensity_sum, length(linear_filter_stimulus));
StimuliList = [linear_filter_stimulus; square_pulse_stimulus; triangle_pulse_stimulus];
[filename, pathname] = uiputfile('*.txt','Save Stimuli As');
dlmwrite(fullfile(pathname, filename), StimuliList,'delimiter','\t');

% trials = 5;
% frame_count = 25600;
% minVoltage = 0;
% pulse_wait = 140;
% 
% stimuli_order = [];
% for i = 1:size(StimuliList,1)
%     for trial = 1:trials
%         stimuli_order = cat(2, stimuli_order, i);
%     end
% end
% stimuli_order = stimuli_order(:,randperm(size(stimuli_order,2)));
% 
% 
% voltages = zeros(1,frame_count);
% stimulus_off = 1;
% step_count = 0;
% stimulus_index = 1;
% currentVoltage = minVoltage;
% 
% for frame = 1:frame_count
%     voltages(1,frame) = currentVoltage;
%     if stimulus_off
%         if step_count >= pulse_wait
%             if stimulus_index > size(stimuli_order,2)
%                %end of the pulse arrary reached, do nothing
%                currentVoltage = minVoltage;
%             else
%                 stimulus_off = 0;
%                 step_count = 1;
%                 currentVoltage = StimuliList(stimuli_order(1,stimulus_index), step_count);
%             end
%         end
%     else
%         if step_count > size(StimuliList,2);
%             stimulus_off = 1;
%             step_count = 0;
%             currentVoltage = minVoltage;
%             stimulus_index = stimulus_index + 1;
%         else
%             currentVoltage = StimuliList(stimuli_order(1,stimulus_index), step_count);
%         end
%     end
%     step_count = step_count + 1;
% end
% plot(voltages)
% plot(StimuliList(3,:));