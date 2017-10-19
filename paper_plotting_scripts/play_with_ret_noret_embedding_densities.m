%PlotWatershed([vertcat(allTracks_GWN_ret(:).Embeddings);vertcat(allTracks_GWN_noret(:).Embeddings)]);
relevant_track_fields = {'Embeddings','Frames'};    
load('reference_embedding.mat')

%select folders
% folders_GWN_ret = getfoldersGUI();
% folders_GWN_noret = getfoldersGUI();

%ret
[allTracks_GWN_ret, folder_indecies_GWN_ret, track_indecies_GWN_ret] = loadtracks(folders_GWN_ret,relevant_track_fields);
%noret
[allTracks_GWN_noret, folder_indecies_GWN_noret, track_indecies_GWN_noret] = loadtracks(folders_GWN_noret,relevant_track_fields);

PlotWatershed(vertcat(allTracks_GWN_ret(:).Embeddings));
figure
PlotWatershed(vertcat(allTracks_GWN_noret(:).Embeddings));

figure
density = PlotWatershedDifference(vertcat(allTracks_GWN_ret(:).Embeddings),vertcat(allTracks_GWN_noret(:).Embeddings));
