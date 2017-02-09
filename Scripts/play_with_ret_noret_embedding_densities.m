%PlotWatershed([vertcat(allTracks_GWN_ret(:).Embeddings);vertcat(allTracks_GWN_noret(:).Embeddings)]);
% 
% PlotWatershed(vertcat(allTracks_GWN_ret(:).Embeddings));
% figure
% PlotWatershed(vertcat(allTracks_GWN_noret(:).Embeddings));

figure
density = PlotWatershedDifference(vertcat(allTracks_GWN_ret(:).Embeddings),vertcat(allTracks_GWN_noret(:).Embeddings));
