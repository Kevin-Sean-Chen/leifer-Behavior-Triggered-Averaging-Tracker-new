fps = 14;
ProjectedEigenvalues = allTracks(2).ProjectedEigenValues;


full_reconstruction = PCA_Reconstruction(ProjectedEigenvalues, EigenVectors, 19);
reduced_reconstruction =  PCA_Reconstruction(ProjectedEigenvalues, EigenVectors, 5);

figure
hold all
% plot(full_reconstruction(:,105*fps));
% plot(reduced_reconstruction(:,105*fps));
plot(reduced_reconstruction(:,30*fps),'linewidth', 3);
plot(full_reconstruction(:,30*fps),'linewidth', 3);
ylabel('Angle (radians)');

hold off


figure
for i = 1:parameters.pcaModes
    subplot(parameters.pcaModes, 1, i)
    plot(ProjectedEigenvalues(i,:));
    ax = gca;
    ylabel({['PC ', num2str(i)], 'Loading (a.u)'});
    ylim([-10 10]);
    xlim([1 length(ProjectedEigenvalues(i,:))]);
    ax.XTick = [0, 30*fps, 60*fps, 90*fps, 120*fps, 150*fps];
    ax.XTickLabel = round(ax.XTick/parameters.samplingFreq);
    
    if i == length(pcaSpectra)
        xlabel('Time (s)');
    end
end

plot_data = flipud(Spectra{2}');
pcaSpectra = flipud(mat2cell(plot_data, repmat(parameters.numPeriods, 1, parameters.pcaModes)));
%pcaSpectra{5} = pcaSpectra{2} - pcaSpectra{3};
figure
for i = 1:length(pcaSpectra)
    subplot(length(pcaSpectra), 1, i)
    imagesc(pcaSpectra{i});
    ax = gca;
    ax.YTick = 1:5:parameters.numPeriods;
    ax.YTickLabel = num2cell(round(f(mod(1:length(f),5) == 1), 1));
    ylabel({['PCA Mode ', num2str(i)], 'Frequency (Hz)'});
    
    xlim([1 length(ProjectedEigenvalues(i,:))]);
    ax.XTick = [0, 30*fps, 60*fps, 90*fps, 120*fps, 150*fps];
    ax.XTickLabel = round(ax.XTick/parameters.samplingFreq);
    
    if i == length(pcaSpectra)
        xlabel('Time (s)');
    end
end