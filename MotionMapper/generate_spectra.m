function [Spectra, SpectraFrames, SpectraTracks, f] = generate_spectra(allTracks, parameters, Prefs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    Projections = {allTracks.ProjectedEigenValues};
    L = length(Projections);
    Spectra = cell(1,L); %full wavelet transform
    SpectraFrames = cell(1,L); %keep track of each datapoint's frame indecies
    SpectraTracks = cell(1,L); %keep track of each datapoint's track index
    %datapoint_count = 1;
    for track_index = 1:L
        [feature_vector,f] = findWavelets(Projections{track_index}',parameters.pcaModes,parameters);  

        %find phase velocity and add it to the spectra
        phi_dt = worm_phase_velocity(allTracks(track_index).ProjectedEigenValues, Prefs)';

        %using phase velocity directly option
%         Spectra{track_index} = [feature_vector, phi_dt];

        %binary option
        forward_vector = zeros(length(phi_dt),1);
        forward_vector(phi_dt > 0) = 1;
        forward_vector = forward_vector + 1;
    %     forward_vector = forward_vector ./ parameters.pcaModes ./ 2; %scale it as 1 PCA mode
        Spectra{track_index} = [feature_vector, forward_vector];

%         %no phase velocity option
%         Spectra{track_index} = feature_vector;
        
        SpectraFrames{track_index} = 1:size(Spectra{track_index},1);
        SpectraTracks{track_index} = repmat(track_index,1,size(Spectra{track_index},1));

    end

end

