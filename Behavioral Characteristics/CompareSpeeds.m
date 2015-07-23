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
%randomly draw out tracks
% track_indecies = randperm(length(allTracks));
% track_indecies = track_indecies(1:5);
% track_indecies = 1:28;
% CompareHistograms(SpeedDistribution(allTracks(track_indecies)));
% distribution1 = SpeedDistribution(allTracks(track_indecies));
distribution1 = SpeedDistribution(allTracks);

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
% track_indecies = 1:23;
% distribution2 = SpeedDistribution(allTracks(track_indecies));
distribution2 = SpeedDistribution(allTracks);

CompareTwoHistograms(distribution1, distribution2, 'GC6', 'N2')
xlabel('Speed (mm/s)')
%ylabel('Count, Track*sec')
ylabel('Count, (Frames)')

figure
grouping = char(zeros(length(distribution1) + length(distribution2),3));
grouping(1:length(distribution1),:) = repmat('GC6',length(distribution1),1);
grouping(length(distribution1)+1:length(distribution1)+length(distribution2),:) = repmat('N2 ',length(distribution2),1);
boxplot([distribution1, distribution2],grouping)
xlabel('Strains')
ylabel('Speed (mm/s)')