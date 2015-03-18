fps = 14;
seconds_before = 10;
seconds_after = 1;
allTracks = struct([]);

while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        allFiles = dir(); %get all the tif files
        load('tracks.mat')
        if length(allTracks) == 0
            allTracks = Tracks;
        else
            allTracks = [allTracks, Tracks];
        end        
    end
end


tracksCentered = [];
pirouetteCount = 0;

for track = 1:length(allTracks)
    pirouettes = allTracks(track).Pirouettes;
    for pirouette_index = 1:size(pirouettes,1)
        pirouetteStart = pirouettes(pirouette_index,1);
        LEDVoltages = allTracks(track).LEDVoltages;
        if pirouetteStart - (fps*seconds_before) < 1 || pirouetteStart + (fps*seconds_after) > length(LEDVoltages)
            %pad voltages with 0s if needed
%             buffer = zeros(1, 50 - pirouetteStart);
%             tracksCentered = cat(1, tracksCentered, cat(2, buffer, LEDVoltages(:, 1:pirouetteStart+5)));
        else
            tracksCentered = cat(1, tracksCentered, LEDVoltages(:, pirouetteStart-(fps*seconds_before):pirouetteStart+(fps*seconds_after)));
            pirouetteCount = pirouetteCount + 1;
        end
    end
end

%plot(-seconds_before:1/fps:seconds_after, mean(diff(tracksCentered,1)))
plot(-seconds_before:1/fps:seconds_after, mean(tracksCentered,1))
%legend(num2str(tracksByVoltage(voltage_index).voltage));
xlabel(strcat('second (', num2str(pirouetteCount), ' reversals analyzed)')) % x-axis label
ylabel('voltage') % y-axis label

load('LEDVoltages.txt')

% figure
% plot(0:1/fps:(size(LEDVoltages,2)-1)/fps, LEDVoltages)
% xlabel(strcat('time (s)')) % x-axis label
% ylabel('voltage') % y-axis label

