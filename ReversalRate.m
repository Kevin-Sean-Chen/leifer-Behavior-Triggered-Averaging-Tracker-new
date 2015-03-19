fps = 14;

allTracks = struct([]);
%divide bins by minute
reversal_counts = zeros(1, ceil(parameters(6) / fps / 60));
frame_count = zeros(1, ceil(parameters(6) / fps / 60));
tracksCentered = [];
pirouetteCount = 0;

while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        allFiles = dir(); %get all the tif files
        load('tracks.mat')
        load('parameters.txt')
        allTracks = Tracks;
        for track = 1:length(allTracks)
            pirouettes = allTracks(track).Pirouettes;
            frames = allTracks(track).Frames;
            for pirouette_index = 1:size(pirouettes,1)
                pirouetteStart = pirouettes(pirouette_index,1);
                reversal_counts(ceil(frames(pirouetteStart) / fps / 60)) = reversal_counts(ceil(frames(pirouetteStart) / fps / 60)) + 1;
            end
            for frame_index = 1:length(frames)
                frame_count(ceil(frames(frame_index) / fps / 60)) = frame_count(ceil(frames(frame_index) / fps / 60)) + 1;
            end
        end
    end
end

plot(reversal_counts./frame_count * fps * 60, 'bo-')
%legend(num2str(tracksByVoltage(voltage_index).voltage));
xlabel(['minutes (', num2str(sum(reversal_counts)), ' reversals analyzed)']) % x-axis label
ylabel('reversals per worm per min') % y-axis label