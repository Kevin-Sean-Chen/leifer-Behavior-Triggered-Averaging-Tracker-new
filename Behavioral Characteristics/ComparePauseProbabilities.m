fps = 14;
% strains = {'N2', 'GC6 Extrachromosomal', 'GC6 Integrated'};
% strains = {'N2 Agar Plate', 'GCaMP6 Agar Plate', 'GCaMP6 Whole-Brain'};
strains = {'N2', 'AML341', 'AML342', 'AML32'};
relevant_fields = {'Frames', 'Pauses'};
% sample_number = 100;
grouping = {};
distribution = [];
% randsample_distribution = [];

all_folders = {};
for strain_index = 1:length(strains)
    disp(['select folders for ' strains{strain_index}])
    folders = getfoldersGUI();
    all_folders{strain_index} = folders;
end

for strain_index = 1:length(strains)
    folders = all_folders{strain_index};
    allTracks = [];
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        Tracks = load_single_folder(folder_name, relevant_fields);
        allTracks = [allTracks, FilterUniqueTracks(Tracks)];
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
%     randsample_distribution = catpad(2, randsample_distribution, datasample(PauseProbability,sample_number));
end

for strain_index = 1:length(strains)
%     grouping = [grouping, repmat(strains(strain_index),1,length(randsample_distribution))'];
    grouping = [grouping, repmat(strains(strain_index),1,length(distribution))'];
end

% grouping{1,3} = 'Worm 1';
% grouping{2,3} = 'Worm 2';
% grouping{3,3} = 'Worm 5';
% grouping{4,3} = 'Worm 6';

figure
% plotSpread(distribution, 'xNames', strains, 'categoryIdx', grouping, 'categoryMarkers', {'x','x','+','o','*','^','x'}, 'categoryColor', {'b','b','g','k','c','m','b'}, 'showMM', 5)
plotSpread(distribution, 'xNames', strains, 'categoryIdx', grouping, 'categoryMarkers', {'x','x','x','x'}, 'categoryColor', {'b','b','b','b'}, 'showMM', 5)
% plotSpread(randsample_distribution, 'xNames', strains, 'categoryIdx', grouping, 'categoryMarkers', {'x','x','x','x'}, 'categoryColor', {'b','b','b','b'}, 'showMM', 5)
% xlabel('Strains')
ylabel('Fraction of Time Paused')
axis([0.5 4.5 -0.05 0.30])
set(gcf, 'Position', [100, 100, 800, 500]);