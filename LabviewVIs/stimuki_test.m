frame_count = 500;
correlationTime = 0.5;
maxPower = 5;
minPower = 0;
currentPower = 2.5;
sigma = 2;

powers = zeros(1,frame_count);
frame_rate = 14;
A = exp(-(1/frame_rate)/correlationTime);
powers(1,1) = 0; %the initial voltage is 0, we will offset later

for frame = 2:frame_count
    powers(1,frame) = A*powers(1,frame-1) + (randn(1)*sqrt(sigma^2*(1-(A^2))));
end

%offset
powers = powers + currentPower;

%make sure the signal does not go out of bounds
powers(powers<minPower) = minPower;
powers(powers>maxPower) = maxPower;