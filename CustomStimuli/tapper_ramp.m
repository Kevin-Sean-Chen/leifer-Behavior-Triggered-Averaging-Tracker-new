VoltageList = [1,28];
trials = 3;
minVoltage = 0;
pulse_duration = 280; %the ISI
pulse_wait = 56; %amount of time to hold the solenoid

maxVoltage = 5;
pulse_voltages = []
for i = 1:size(VoltageList,2)
    for trial = 1:trials
        pulse_voltages = cat(2, pulse_voltages, VoltageList(i))
    end
end
pulse_voltages = pulse_voltages(:,randperm(size(pulse_voltages,2)))


voltages = []
for pulse_index = 1:length(pulse_voltages)
    increase_frames = pulse_voltages(pulse_index);
    pulse = linspace(0,maxVoltage,increase_frames);
    pulse = [pulse, repmat(maxVoltage,1,pulse_wait)];
    current_pulse = zeros(1,pulse_duration);
    pulse_length = min(length(pulse),length(current_pulse));
    current_pulse(1:pulse_length) = pulse(1:pulse_length);
    voltages = [voltages, current_pulse];
end

frame_count = length(voltages);