%% Select data folder (and subfolders) to work with
folders = getfoldersGUI();
%%
% relevant .mat files. Each row is a worm
relevant_fields = {'Frames','BehavioralTransition','Behaviors'};
Tracks = loadtracks(folders, relevant_fields);
track_index = 3;
turning_frames=Tracks(track_index).Frames(Tracks(track_index).Behaviors(9,:));

