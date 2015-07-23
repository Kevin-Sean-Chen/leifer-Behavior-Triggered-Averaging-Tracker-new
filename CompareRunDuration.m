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

RunDurations = reshape(vertcat(allTracks.Runs), [], 2);
RunDurations = RunDurations(:,2) - RunDurations(:,1);
distribution1 = RunDurations' / fps;

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

RunDurations = reshape(vertcat(allTracks.Runs), [], 2);
RunDurations = RunDurations(:,2) - RunDurations(:,1);
distribution2 = RunDurations' / fps;

CompareTwoHistograms(distribution1, distribution2, 'GC6', 'N2')
xlabel('Ran Duration (s)')
ylabel('Count')