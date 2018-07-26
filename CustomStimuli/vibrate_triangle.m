frame_count = 700;
frequency = 1000;
currentDutyCycle = 25;
maxDutyCylce = 50;
minDutyCycle = 0;
sigma = 25;
correlationTime = 0.5;

duty_cycles = zeros(1,frame_count);
frame_rate = 14;
A = exp(-(1/frame_rate)/correlationTime);
duty_cycles(1,1) = 0; %the initial voltage is 0, we will offset later

for frame = 2:frame_count
    duty_cycles(1,frame) = A*duty_cycles(1,frame-1) + (randn(1)*sqrt(sigma^2*(1-(A^2))));
end

%offset
duty_cycles = duty_cycles + currentDutyCycle;

%make sure the signal does not go out of bounds
duty_cycles(duty_cycles<minDutyCycle) = minDutyCycle;
duty_cycles(duty_cycles>maxDutyCylce) = maxDutyCylce;

frequencies = ones(1,frame_count) * frequency;

plot(duty_cycles)