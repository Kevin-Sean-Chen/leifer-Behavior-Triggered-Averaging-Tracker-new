period = 70;
frame_count = 700;
frequency = 1000;
currentDutyCycle = 0;
maxDutyCylce = .5;
minDutyCycle = 0;

duty_cycles = zeros(1,frame_count);
rising = true;
step = 2*(maxDutyCycle - minDutyCycle)/period;
for frame = 1:frame_count
    duty_cycles(1,frame) = currentDutyCycle;
    if rising
        if currentDutyCycle >= maxDutyCycle
            rising = false;
            currentDutyCycle = currentDutyCycle - step;
        else
            currentDutyCycle = currentDutyCycle + step;
        end
    else
        if currentDutyCycle <= minDutyCycle
            rising = true;
            currentDutyCycle = currentDutyCycle + step;
        else
            currentDutyCycle = currentDutyCycle - step;
        end
    end
end
frequencies = ones(1,frame_count) * frequency;

plot(duty_cycles)