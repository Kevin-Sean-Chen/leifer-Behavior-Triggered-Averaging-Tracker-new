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

PauseDuration = reshape(vertcat(allTracks.Pauses), [], 2);
PauseDuration = PauseDuration(:,2) - PauseDuration(:,1);
distribution1 = PauseDuration' / fps;

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

PauseDuration = reshape(vertcat(allTracks.Pauses), [], 2);
PauseDuration = PauseDuration(:,2) - PauseDuration(:,1);
distribution2 = PauseDuration' / fps;

CompareTwoHistograms(distribution1, distribution2, 'GC6', 'N2')
xlabel('Pause Duration (s)')
ylabel('Count')