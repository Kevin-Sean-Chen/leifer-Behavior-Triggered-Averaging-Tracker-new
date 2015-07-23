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
        allTracks = [allTracks, FilterUniqueTracks(Tracks)];
    end
end


PirouetteProbability = zeros(1,length(allTracks));
for track_index = 1:length(allTracks)
    currentTrack = allTracks(track_index);
    PirouetteProbability(track_index) = size(currentTrack.Pirouettes,1)/length(currentTrack.Frames)*fps*60;
end

distribution1 = PirouetteProbability;

allTracks = [];
%get second distribution
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        allTracks = [allTracks, FilterUniqueTracks(Tracks)];
    end
end

PirouetteProbability = zeros(1,length(allTracks));
for track_index = 1:length(allTracks)
    currentTrack = allTracks(track_index);
    PirouetteProbability(track_index) = size(currentTrack.Pirouettes,1)/length(currentTrack.Frames)*fps*60;
end

distribution2 = PirouetteProbability;

CompareTwoHistograms(distribution1, distribution2, 'GC6', 'N2')
xlabel('Reversal Rate (reversals/min)')
ylabel('Count')

figure
grouping = char(zeros(length(distribution1) + length(distribution2),3));
grouping(1:length(distribution1),:) = repmat('GC6',length(distribution1),1);
grouping(length(distribution1)+1:length(distribution1)+length(distribution2),:) = repmat('N2 ',length(distribution2),1);
boxplot([distribution1, distribution2],grouping)
xlabel('Strains')
ylabel('Reversal Rate (reversals/min)')