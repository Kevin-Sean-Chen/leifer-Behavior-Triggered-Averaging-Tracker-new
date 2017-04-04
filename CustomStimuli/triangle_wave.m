period = 280;
frame_count = 280;
VoltageToPower = 1;
currentPower = 0;
maxPower = 5;
minPower = 0;

powers = zeros(1,frame_count);
rising = true;
step = 2*(maxPower - minPower)/period;
for frame = 1:frame_count
    powers(1,frame) = currentPower;
    if rising
        if currentPower >= maxPower
            rising = false;
            currentPower = currentPower - step;
        else
            currentPower = currentPower + step;
        end
    else
        if currentPower <= minPower
            rising = true;
            currentPower = currentPower + step;
        else
            currentPower = currentPower - step;
        end
    end
end

voltages = powers / VoltageToPower; %convert to voltages;

plot(voltages)