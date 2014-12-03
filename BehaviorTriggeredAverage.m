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

tracksCentered = [];

for track = 1:length(allTracks)
    pirouettes = allTracks(track).Pirouettes;
    for pirouette_index = 1:size(pirouettes,1)
        pirouetteStart = pirouettes(pirouette_index,1);
        LEDVoltages = allTracks(track).LEDVoltages;
      
        if pirouetteStart - 199 < 1
            %pad voltages with 0s if needed
%             buffer = zeros(1, 50 - pirouetteStart);
%             tracksCentered = cat(1, tracksCentered, cat(2, buffer, LEDVoltages(:, 1:pirouetteStart+5)));
        else
            tracksCentered = cat(1, tracksCentered, LEDVoltages(:, pirouetteStart-199:pirouetteStart+5));
        end
    end
end

plot(-199:5, mean(diff(tracksCentered),1))
%legend(num2str(tracksByVoltage(voltage_index).voltage));
xlabel('') % x-axis label
ylabel('sine and cosine values') % y-axis label
