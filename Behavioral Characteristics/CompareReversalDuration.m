fps = 14;
allTracks = [];

%get first distribution
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        allTracks = [allTracks, Tracks];
    end
end

PirouettesDuration = reshape(vertcat(allTracks.Pirouettes), [], 2);
PirouettesDuration = PirouettesDuration(:,2) - PirouettesDuration(:,1);
distribution1 = PirouettesDuration' / fps;

allTracks = [];
%get second distribution
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        allTracks = [allTracks, Tracks];
    end
end

PirouettesDuration = reshape(vertcat(allTracks.Pirouettes), [], 2);
PirouettesDuration = PirouettesDuration(:,2) - PirouettesDuration(:,1);
distribution2 = PirouettesDuration' / fps;

CompareTwoHistograms(distribution1, distribution2, 'GC6', 'N2')
xlabel('Reversal Duration (s)')
ylabel('Count')