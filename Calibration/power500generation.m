%calibrate box
power_reading = 4.97; %in mW
power_per_mm = power_reading*1000./71; %in uW/mm^2


% load mask
[filename,pathname] = uigetfile('*.png','Load probe mask image');
probemask = ~im2bw(imread([pathname,'\',filename]));
probemask = probemask(:);

%load power500
[filename,pathname] = uigetfile('*.png','Load Image of Power at 500 mA');

power500 = imread([pathname,'\',filename]);
linear_power500 = power500(:);

avg_probe_intensity = mean(linear_power500(probemask));


power500 = imgaussfilt(power500,100);
power500 = double(power500).*power_per_mm./avg_probe_intensity;


imagesc(power500)
colorbar
mean(power500(:))