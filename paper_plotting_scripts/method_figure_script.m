%load tracks
relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'Spectra', 'Centerlines', 'LEDVoltage2Power', 'ProjectedEigenValues'};

%select folders
%folders = getfolders();
%[allTracks, folder_indecies, track_indecies] = loadtracks(folders,relevant_track_fields);
parameters = load_parameters(folders{1});

worm_index = 16; %of Z:\20170828_AML67_GWN\Data20170828_110923

%% plotting the eigenworms 
%plot the first 5 principle components
PCsToPlot = 5;
EigenVectors = parameters.EigenVectors;
figure
hold all
%my_legend = {};
for pc = 1:PCsToPlot
    %subplot(4,ceil(PCsToPlot/4),pc)
    subplot(PCsToPlot,1,pc)
    plot(1:length(EigenVectors), EigenVectors(:,pc), 'linewidth', 3, 'color', 'k')
    xlabel('Position Along the Worm')
    ylabel(['PC', num2str(pc), ' Loadings'])
    if pc == 4
        ylim([-0.4 0])
    else
        ylim([-0.4 0.4])
    end
    %my_legend = [my_legend, ['PC', num2str(pc)]];
    %('PC Loadings')
end
%legend(my_legend)

%% Plotting PCA timeseries
fps = 14;
ProjectedEigenvalues = allTracks(worm_index).ProjectedEigenValues;

figure
for i = 1:parameters.pcaModes
    subplot(parameters.pcaModes, 1, i)
    plot(ProjectedEigenvalues(i,:),'k', 'linewidth', 3);
    ax = gca;
    ylabel({['PC ', num2str(i)], 'Loading (a.u)'});
    ylim([-10 10]);
    xlim([1 length(ProjectedEigenvalues(i,:))]);
    ax.XTick = [0, 10*fps, 20*fps, 30*fps, 40*fps, 50*fps];
    ax.XTickLabel = round(ax.XTick/parameters.samplingFreq);
    
%     if i == length(pcaSpectra)
%         xlabel('Time (s)');
%     end
end

%% plot Spectra
plot_data = flipud(allTracks(worm_index).Spectra(:,1:parameters.numPeriods*parameters.pcaModes)');
pcaSpectra = flipud(mat2cell(plot_data, repmat(parameters.numPeriods, 1, parameters.pcaModes)));
omega0 = parameters.omega0;
numPeriods = parameters.numPeriods;
dt = 1 ./ parameters.samplingFreq;
minT = 1 ./ parameters.maxF;
maxT = 1 ./ parameters.minF;
f = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
f = 1./f;

maxVal = max(plot_data(:));

figure
for i = 1:length(pcaSpectra)
    subplot(length(pcaSpectra), 1, i)
    imagesc(pcaSpectra{i});
    caxis([0, maxVal]);
    ax = gca;
    ax.YTick = 1:5:parameters.numPeriods;
    ax.YTickLabel = num2cell(round(f(mod(1:length(f),5) == 1), 1));
    %ylabel({['PCA Mode ', num2str(i)], 'Frequency (Hz)'});
    
    xlim([1 length(ProjectedEigenvalues(i,:))]);
    ax.XTick = [0, 10*fps, 20*fps, 30*fps, 40*fps, 50*fps];
    ax.XTickLabel = round(ax.XTick/parameters.samplingFreq);
end
%colormap(parula);

subplot(length(pcaSpectra)+1, 1, length(pcaSpectra)+1)
imagesc(allTracks(worm_index).Spectra(:,end)');
colormap(flipud(othercolor('Reds3')));
%colorbar
caxis([min(allTracks(worm_index).Spectra(:,end)), max(allTracks(worm_index).Spectra(:,end))]);
ax = gca;
xlim([1 length(ProjectedEigenvalues(i,:))]);
ax.XTick = [0, 10*fps, 20*fps, 30*fps, 40*fps, 50*fps];
ax.XTickLabel = round(ax.XTick/parameters.samplingFreq);

xlabel('Time (s)');

%% Picking points and plotting in embedding
time_points = [10, 18, 21, 40]; %in sec
frame_indecies = time_points .* fps;
point_colors = lines(length(time_points));
selected_embeddings = allTracks(worm_index).Embeddings(frame_indecies,:);

figure
hold on
PlotWatershed;
scatter(selected_embeddings(:,1),selected_embeddings(:,2), 100, point_colors, 'filled', 'LineWidth', 2, 'MarkerEdgeColor', 'w')
