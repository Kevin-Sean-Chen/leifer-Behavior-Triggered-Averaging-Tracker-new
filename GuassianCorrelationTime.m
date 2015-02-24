frame_count = 140;
correlationTime = 0.5;
sigma = 0.2; %the standard deviation
minVoltage = 0;
maxVoltage = 5;
currentVoltage = 0.3; %in this case, the average voltage
fps = 14;

voltages = zeros(1,frame_count);
frame_rate = 14;
A = exp(-(1/frame_rate)/correlationTime);
voltages(1,1) = 0; %the initial voltage is 0, we will offset later

for frame = 2:frame_count
    voltages(1,frame) = A*voltages(1,frame-1) + (randn(1)*sqrt(sigma^2*(1-(A^2))));
end

%offset
voltages = voltages + currentVoltage;

%make sure the signal does not go out of bounds
voltages(voltages<minVoltage) = minVoltage;
voltages(voltages>maxVoltage) = maxVoltage;

plot(0:1/fps:(frame_count-1)/fps, voltages, 'bo-')
xlabel('time (s)') % x-axis label
ylabel('voltage') % y-axis label