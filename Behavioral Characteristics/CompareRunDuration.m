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
    
%     RunDurations = reshape(vertcat(allTracks.Runs), [], 2);
%     RunDurations = RunDurations(:,2) - RunDurations(:,1);
%     
%     %do not count the beginning run or end run lengths because they are cut off
%     RunDurations(1) = []; 
%     RunDurations(end) = [];
    RunDurations = [];
    for track_index = 1:length(allTracks)
        AverageRunDuration = 0;
        if size(allTracks(track_index).Runs,1) > 2
            current_RunDurations = allTracks(track_index).Runs(:,2) - allTracks(track_index).Runs(:,1);
            %do not count the beginning run or end run lengths because they are cut off
            current_RunDurations(1) = []; 
            current_RunDurations(end) = [];
            AverageRunDuration = mean(current_RunDurations);
        end
        RunDurations = [RunDurations; AverageRunDuration];
    end

    strains{strain_index} = [strains{strain_index},' (n = ',num2str(length(RunDurations)),')'];    
%     grouping = [grouping, repmat(strains(strain_index),1,length(RunDurations))];
    distribution = catpad(2,distribution,RunDurations);
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
ylabel('Average Ran Duration (s)')
axis([0.5 3.5 -500 2500])
set(gcf, 'Position', [100, 100, 800, 500]);