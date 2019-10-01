% used for calibration; not in paper

curDir = uigetdir
cd(curDir) %open the directory of image sequence
image_files=dir('*.tif'); %get all the tif files


%get min z projection
intensity = zeros(length(image_files)-1,1);
for frame_index = 1:length(image_files)-1
    curImage = imread(image_files(frame_index).name);
    curImage = curImage(872:1072,1196:1396);
    intensity(frame_index,1) = mean(mean(curImage,1),2);
end

% Load Voltages
fid = fopen('LEDVoltages.txt');
LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
fclose(fid);
if length(LEDVoltages) > length(image_files) && mod(length(LEDVoltages),length(image_files)) == 0
    %reshape LEDVoltages in multistim mode
    LEDVoltages = reshape(LEDVoltages,[length(LEDVoltages)/length(image_files),length(image_files)]);
end

%normalize
intensity = transpose(intensity);
intensity = intensity - min(intensity);
intensity = intensity / max(intensity);
find(intensity == min(intensity))
find(intensity == max(intensity))

LEDVoltages = LEDVoltages - min(LEDVoltages);
LEDVoltages = LEDVoltages / max(LEDVoltages);
find(LEDVoltages == min(LEDVoltages))
find(LEDVoltages == max(LEDVoltages))

figure
hold on;
plot(1:size(LEDVoltages,2), LEDVoltages, 'color', 'r', 'DisplayName', 'input voltage')
plot(1:size(intensity,2), intensity, 'color', 'b', 'DisplayName', 'image intensity')
hold off;
legend('show');