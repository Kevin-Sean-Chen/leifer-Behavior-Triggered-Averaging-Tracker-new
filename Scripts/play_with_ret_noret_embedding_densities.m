PlotWatershed(vertcat(retTracks(:).Embeddings));
figure
PlotWatershed(vertcat(noretTracks(:).Embeddings));

figure
PlotWatershedDifference(vertcat(retTracks(:).Embeddings),vertcat(noretTracks(:).Embeddings));
