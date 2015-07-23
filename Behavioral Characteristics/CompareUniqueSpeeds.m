fps = 14;
strains = {'N2 Agar Plate', 'GCaMP6 Agar Plate', 'GCaMP6 Whole-Brain'};
% strains = {'N2 6/08', 'N2 6/18', 'N2 7/13'};
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
    
    averageSpeed = SpeedDistribution(allTracks);
    strains{strain_index} = [strains{strain_index},' (n = ',num2str(length(allTracks)),')'];    
%     grouping = [grouping, repmat(strains(strain_index),1,length(averageSpeed))];
    distribution = catpad(2,distribution, SpeedDistribution(allTracks)');
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
ylabel('Average Speed (mm/s)')
axis([0.5 3.5 0 0.3])
set(gcf, 'Position', [100, 100, 800, 500]);