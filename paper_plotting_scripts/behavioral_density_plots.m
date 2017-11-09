relevant_track_fields = {'BehavioralTransition','Frames','Embeddings'};    

%select folders
%folders_GWN_ret = getfoldersGUI();
%folders_GWN_noret = getfoldersGUI();

%ret
[allTracks_GWN_ret, folder_indecies_GWN_ret, track_indecies_GWN_ret] = loadtracks(folders_GWN_ret,relevant_track_fields);
%noret
[allTracks_GWN_noret, folder_indecies_GWN_noret, track_indecies_GWN_noret] = loadtracks(folders_GWN_noret,relevant_track_fields);


%PlotWatershed(vertcat(allTracks.Embeddings));

PlotWatershed(vertcat(allTracks_GWN_ret.Embeddings, allTracks_GWN_noret.Embeddings));

