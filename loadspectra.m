function [ Spectra, SpectraFrames, SpectraTracks, Amps, f ] = loadspectra(folders, parameters, Prefs)
%get the spectra given folders, incomplete function
    folder_indecies = [];
    track_indecies = [];

    SpectraFrames = cell(1,L); %keep track of each datapoint's frame indecies
    SpectraTracks = cell(1,L); %keep track of each datapoint's track index

    
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

