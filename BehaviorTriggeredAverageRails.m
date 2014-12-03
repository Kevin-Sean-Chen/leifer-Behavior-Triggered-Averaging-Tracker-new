folder_name = uigetdir
cd(folder_name) %open the directory of image sequence
allFiles = dir(); %get all the tif files
allTracks = struct([]);
for file_index = 1: length(allFiles)
    if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
        cd(strcat(folder_name, '\', allFiles(file_index).name))
        load('tracks.mat')
        if length(allTracks) == 0
            allTracks = Tracks;
        else
            allTracks = [allTracks, Tracks];
        end
    end
end 

tracksByVoltage = struct('voltage', {}, 'pirouette_centered_LEDVoltages', {});


for track = 1:length(allTracks)
    pirouettes = allTracks(track).Pirouettes;
    for pirouette_index = 1:size(pirouettes,1)
        pirouetteStart = pirouettes(pirouette_index,1);
        LEDVoltages = allTracks(track).LEDVoltages;
        maxVoltage = max(LEDVoltages);
        if length(find([tracksByVoltage.voltage] == maxVoltage)) == 0
            %no entry with this max voltage before
            trackByVoltageIndex = length(tracksByVoltage) + 1;
            tracksByVoltage(trackByVoltageIndex).voltage = maxVoltage;
            tracksByVoltage(trackByVoltageIndex).pirouette_centered_LEDVoltages = [];
        else
            trackByVoltageIndex = find([tracksByVoltage.voltage] == maxVoltage);
        end
        
        if pirouetteStart - 49 < 1
            %pad voltages with 0s if needed
            buffer = zeros(1, 50 - pirouetteStart);
            tracksByVoltage(trackByVoltageIndex).pirouette_centered_LEDVoltages = cat(1, tracksByVoltage(trackByVoltageIndex).pirouette_centered_LEDVoltages, cat(2, buffer, LEDVoltages(:, 1:pirouetteStart+5)));
        else
            tracksByVoltage(trackByVoltageIndex).pirouette_centered_LEDVoltages = cat(1, tracksByVoltage(trackByVoltageIndex).pirouette_centered_LEDVoltages, LEDVoltages(:, pirouetteStart-49:pirouetteStart+5));
        end
    end
end

tracksByVoltage = nestedSortStruct(tracksByVoltage, 'voltage'); %sort it

mymarkers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
mycolors = jet(length(tracksByVoltage));
hold on;
for voltage_index = 2:length(tracksByVoltage)
    plot(-49:5, mean(tracksByVoltage(voltage_index).pirouette_centered_LEDVoltages,1)/tracksByVoltage(voltage_index).voltage, 'color', mycolors(voltage_index,:), 'marker', mymarkers{mod(voltage_index,numel(mymarkers))+1}, 'DisplayName', num2str(tracksByVoltage(voltage_index).voltage))
    %legend(num2str(tracksByVoltage(voltage_index).voltage));
end
xlabel('frame number (worm reverses at 0)') % x-axis label
ylabel('probability of stimulus is on') % y-axis label
legend('show');
hold off;