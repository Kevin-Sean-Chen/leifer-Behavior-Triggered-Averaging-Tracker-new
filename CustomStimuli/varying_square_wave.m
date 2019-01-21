PowerList = {16, 8};
trials = 10;
frame_count = 1680;
minPower = 0;
pulse_wait = 826;
pulse_duration = 14;
VoltageToPower = 17/5;

pulse_power = []
for i = 1:size(PowerList,2)
    for trial = 1:trials
        pulse_power = cat(2, pulse_power, PowerList(i))
    end
end
pulse_power = pulse_power(:,randperm(size(pulse_power,2)))


powers = zeros(1,frame_count);
rising = 1;
step_count = 0;
pulse_index = 1;
currentPower = minPower;
for frame = 1:frame_count
    powers(1,frame) = currentPower;
    if rising
        if step_count >= pulse_wait
            if pulse_index > size(pulse_power, 2)
               %end of the pulse arrary reached, do nothing
               currentPower = minPower;
            else
                rising = 0;
                step_count = 0;
                currentPower = pulse_power{1, pulse_index};
                pulse_index = pulse_index + 1;
            end
        end
    else
        if step_count >= pulse_duration
            rising = 1;
            step_count = 0;
            currentPower = minPower;
        end
    end
    step_count = step_count + 1;
end

voltages = powers / VoltageToPower; %convert to voltages

plot(voltages)