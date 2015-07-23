frame_rate = 14;
frame_count = 50400;
stimulusDuration = 8400;
pauseDuration = 8400;
pausing = 1;
maxVoltage = 5;
minVoltage = 0;
currentVoltage = 0.5;
sigma = 1;
correlationTime = 0.5;

A = exp(-(1/frame_rate)/correlationTime);
voltages = [];
    
while (length(voltages) < frame_count)
    if pausing
        voltages = [voltages, zeros(1,pauseDuration)];
        pausing = 0;
    else
        stimulus_voltages = zeros(1,stimulusDuration);
        stimulus_voltages(1,1) = 0; %the initial voltage is 0, we will offset later

        for frame = 2:stimulusDuration
            stimulus_voltages(1,frame) = A*stimulus_voltages(1,frame-1) + (randn(1)*sqrt(sigma^2*(1-(A^2))));
        end

        %offset
        stimulus_voltages = stimulus_voltages + currentVoltage;

        %make sure the signal does not go out of bounds
        stimulus_voltages(stimulus_voltages<minVoltage) = minVoltage;
        stimulus_voltages(stimulus_voltages>maxVoltage) = maxVoltage;
        voltages = [voltages, stimulus_voltages];
        pausing = 1;
    end
end

voltages = voltages(1, 1:frame_count);
plot(voltages)