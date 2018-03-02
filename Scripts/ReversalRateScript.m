%not used in paper

fps = 14;

folder_name = uigetdir
cd(folder_name) %open the directory of image sequence
allFiles = dir(); %get all the tif files
allTracks = struct([]);
% for file_index = 1: length(allFiles)
%     if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
%         cd(strcat(folder_name, '\', allFiles(file_index).name))
load('tracks.mat')
load('parameters.txt')


if length(allTracks) == 0
    allTracks = Tracks;
else
    allTracks = [allTracks, Tracks];
end
%     end
% end 

tracksCentered = [];
pirouetteCount = 0;

%divide bins by minute
reversal_counts = zeros(1, ceil(parameters(6) / fps / 60));

for track = 1:length(allTracks)
    pirouettes = allTracks(track).Pirouettes;
    frames = allTracks(track).Frames;
    for pirouette_index = 1:size(pirouettes,1)
        pirouetteStart = pirouettes(pirouette_index,1);
        reversal_counts(ceil(frames(pirouetteStart) / fps / 60)) = reversal_counts(ceil(frames(pirouetteStart) / fps / 60)) + 1;
    end
end

plot(reversal_counts, 'bo-')
%legend(num2str(tracksByVoltage(voltage_index).voltage));
xlabel(strcat('minutes')) % x-axis label
ylabel('reversals per min') % y-axis label