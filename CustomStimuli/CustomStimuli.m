% peak_voltage = 2;
% linear_filter_stimulus = BTAFilter();
% factor = peak_voltage / max(linear_filter_stimulus);
% linear_filter_stimulus = linear_filter_stimulus * factor;
% intensity_sum = sum(linear_filter_stimulus);
% square_pulse_stimulus = SquarePulse(intensity_sum, length(linear_filter_stimulus));
% triangle_pulse_stimulus = TrianglePulse(intensity_sum, length(linear_filter_stimulus));
% StimuliList = [linear_filter_stimulus; square_pulse_stimulus; triangle_pulse_stimulus];
% [filename, pathname] = uiputfile('*.txt','Save Stimuli As');
% dlmwrite(fullfile(pathname, filename), StimuliList,'delimiter','\t');
% [filename, pathname] = uigetfile('*.*');
% StimuliList = dlmread(fullfile(pathname, filename));

trials = 2;
frame_count = 600;
avgPower = 9;
pulse_wait = 140;
VoltageToPower = 18/5;

stimuli_order = [];
for i = 1:size(StimuliList,1)
    for trial = 1:trials
        stimuli_order = cat(2, stimuli_order, i);
    end
end
stimuli_order = stimuli_order(:,randperm(size(stimuli_order,2)));


powers = zeros(1,frame_count);
stimulus_off = 1;
step_count = 0;
stimulus_index = 1;
currentPower = avgPower;

for frame = 1:frame_count
    powers(1,frame) = currentPower;
    if stimulus_off
        if step_count >= pulse_wait
            if stimulus_index > size(stimuli_order,2)
               %end of the pulse arrary reached, do nothing
               currentPower = avgPower;
            else
                stimulus_off = 0;
                step_count = 1;
                currentPower = StimuliList(stimuli_order(1,stimulus_index), step_count);
            end
        end
    else
        if step_count > size(StimuliList,2);
            stimulus_off = 1;
            step_count = 0;
            currentPower = avgPower;
            stimulus_index = stimulus_index + 1;
        else
            currentPower = StimuliList(stimuli_order(1,stimulus_index), step_count);
        end
    end
    step_count = step_count + 1;
end

voltages = powers / VoltageToPower; %convert to voltages

%make sure the signal does not go out of bounds
voltages(voltages<0) = 0;
voltages(voltages>5) = 5;

plot(voltages)
% plot(StimuliList(3,:));