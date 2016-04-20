function [ allTracks, folder_indecies, track_indecies ] = loadtracks(folders)
%get the tracks given folders
    allTracks = struct([]);
    folder_indecies = [];
    track_indecies = [];

    for folder_index = 1:length(folders)
        curDir = folders{folder_index};
        if exist([curDir, '\tracks.mat'], 'file') == 2
            load([curDir, '\tracks.mat'])
            allTracks = [allTracks, Tracks];
            folder_indecies = [folder_indecies, repmat(folder_index,1,length(Tracks))];
            track_indecies = [track_indecies, 1:length(Tracks)];
        end
    end
end

