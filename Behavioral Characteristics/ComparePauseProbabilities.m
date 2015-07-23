fps = 14;
% strains = {'N2', 'GC6 Extrachromosomal', 'GC6 Integrated'};
strains = {'N2 Agar Plate', 'GCaMP6 Agar Plate', 'GCaMP6 Whole-Brain'};

grouping = {};
distribution = [];
folder_name = [];
for strain_index = 1:length(strains)
    allTracks = [];
    while true
        if isempty(folder_name)
            start_path = '';
        else
            start_path = fileparts(fullfile(folder_name, '..', 'tracks.mat')); %display the parent folder
        end
        folder_name = uigetdir(start_path)
        if folder_name == 0
            break
        else
            cd(folder_name) %open the directory of image sequence
            load('tracks.mat')
            allTracks = [allTracks, FilterUniqueTracks(Tracks)];
        end
    end
    
    PauseProbability = [];
    for track_index = 1:length(allTracks)
        PauseSum = 0;
        if ~isempty(allTracks(track_index).Pauses)
            PauseDurations = allTracks(track_index).Pauses(:,2) - allTracks(track_index).Pauses(:,1);
            PauseSum = sum(PauseDurations);
        end
        PauseProbability = [PauseProbability; PauseSum/length(allTracks(track_index).Frames)];
    end

    strains{strain_index} = [strains{strain_index},' (n = ',num2str(length(PauseProbability)),')'];    
%     grouping = [grouping, repmat(strains(strain_index),1,length(PauseProbability))];
    distribution = catpad(2,distribution, PauseProbability);
end

for strain_index = 1:length(strains)
    grouping = [grouping, repmat(strains(strain_index),1,length(distribution))'];
end

grouping{1,3} = 'Worm 1';
grouping{2,3} = 'Worm 2';
grouping{3,3} = 'Worm 5';
grouping{4,3} = 'Worm 6';

figure
plotSpread(distribution, 'xNames', strains, 'categoryIdx', grouping, 'categoryMarkers', {'x','x','+','o','*','^','x'}, 'categoryColor', {'b','b','g','k','c','m','b'}, 'showMM', 5)
% xlabel('Strains')
ylabel('Fraction of Time Paused')
axis([0.5 3.5 -0.05 0.35])
set(gcf, 'Position', [100, 100, 800, 500]);