function [Spectra, SpectraFrames, SpectraTracks, Amps, f] = generate_spectra(Projections, parameters, Prefs)
%This function gets the wavelet transform given tracks
%   Detailed explanation goes here
%     poolobj = gcp('nocreate'); 
%     if isempty(poolobj)
%         parpool(parameters.numProcessors)
%     end

    L = length(Projections);
    Spectra = cell(1,L); %full wavelet transform
    SpectraFrames = cell(1,L); %keep track of each datapoint's frame indecies
    SpectraTracks = cell(1,L); %keep track of each datapoint's track index
    %datapoint_count = 1;
    for track_index = 1:L
        [feature_vector,f] = findWavelets(Projections{track_index}',parameters.pcaModes,parameters);  

        %find phase velocity and add it to the spectra
        phi_dt = worm_phase_velocity(Projections{track_index}, Prefs)';

%         %using phase velocity directly option
%         %make phase velocity non-zero positive between 1 and 2
%         phi_dt = phi_dt - Prefs.MinPhaseVelocity; 
%         phi_dt = phi_dt ./ (Prefs.MaxPhaseVelocity - Prefs.MinPhaseVelocity);
%         phi_dt = phi_dt + 1;
%         Spectra{track_index} = [feature_vector, phi_dt];

        %binary option
        forward_vector = zeros(length(phi_dt),1);
        forward_vector(phi_dt > 0) = 1;
        forward_vector = forward_vector + 1;
        Spectra{track_index} = [feature_vector, forward_vector];

%         %no phase velocity option
%         Spectra{track_index} = feature_vector;
        
        SpectraFrames{track_index} = 1:size(Spectra{track_index},1);
        SpectraTracks{track_index} = repmat(track_index,1,size(Spectra{track_index},1));

        
%         %debug
%         Track = allTracks(track_index);
%         image_size = [70, 70];
%         direction_vector = [[Track.Speed].*-cosd([Track.Direction]); [Track.Speed].*sind([Track.Direction])];
%         head_vector = reshape(Track.Centerlines(1,:,:),2,[]) - (image_size(1)/2);    
%         %normalize into unit vector
%         head_normalization = hypot(head_vector(1,:), head_vector(2,:));
%         head_vector = head_vector ./ repmat(head_normalization, 2, 1);
%         head_direction_dot_product = dot(head_vector, direction_vector);
% 
%         hold all
%         plot(phi_dt/max(phi_dt))
%         plot(head_direction_dot_product/max(head_direction_dot_product))
%         xlabel('Time (frames)')
%         ylabel('Normalized Phase Velocity and direction vector')
        if ~mod(track_index, 100)
            disp(['spectra generated for ' num2str(track_index) ' of ' num2str(L) ' ' num2str(track_index/L*100) ' percent']);
        end
    end
    
%     poolobj = gcp('nocreate'); 
%     delete(poolobj);
    
    %normalize
    data = vertcat(Spectra{:});

    phi_dt = data(:,end); %get phase velocity
    % phi_dt = phi_dt - min(phi_dt) + eps; % make all values non-zero positive
    % phi_dt = phi_dt ./ max(phi_dt); %normalize to 1
    phi_dt = phi_dt ./ parameters.pcaModes; % weigh the phase velocity as a PCA mode (1/5)

    % normalize the phase velocity
    data = data(:,1:end-1);
    temp_amps = sum(data,2);
    data(:) = bsxfun(@rdivide,data,temp_amps);
    data = [data, phi_dt];

    temp_amps = sum(data,2);
    data(:) = bsxfun(@rdivide,data,temp_amps);

    Amps = cell(1,L);
    
    
    %remake Spectra
    start_index = 1;
    for track_index = 1:length(Spectra)
        end_index = start_index + size(Spectra{track_index},1) - 1;
        Spectra{track_index} = data(start_index:end_index, :);
        Amps{track_index} = temp_amps(start_index:end_index, :);
        start_index = end_index + 1;
    end
    
    f = fliplr(f);
    
    % plot_data = flipud(Spectra{2}');
    % pcaSpectra = flipud(mat2cell(plot_data, repmat(parameters.numPeriods, 1, parameters.pcaModes)));
    % %pcaSpectra{5} = pcaSpectra{2} - pcaSpectra{3};
    % figure
    % for i = 1:length(pcaSpectra)
    %     subplot(length(pcaSpectra), 1, i)
    %     imagesc(pcaSpectra{i});
    %     ax = gca;
    %     ax.YTick = 1:5:parameters.numPeriods;
    %     ax.YTickLabel = num2cell(round(f(mod(1:length(f),5) == 1), 1));
    %     ylabel({['PCA Mode ', num2str(i)], 'Frequency (Hz)'});
    %     
    %     ax.XTickLabel = round(ax.XTick/parameters.samplingFreq, 1);
    %     
    %     if i == length(pcaSpectra)
    %         xlabel('Time (s)');
    %     end
    % end
end

