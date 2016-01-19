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
    
    ax.XTickLabel = round(ax.XTick/parameters.samplingFreq, 1);
    
    if i == length(pcaSpectra)
        xlabel('Time (s)');
    end
end