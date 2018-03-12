load('reference_embedding.mat')

relevant_track_fields = {'BehavioralTransition','Embeddings','Frames','LEDPower','Path'};    

%select folders
folders = getfoldersGUI();
[SaveFileName,SavePathName] = uiputfile('*.mat','Save tracks file name');

%load tracks
[Tracks, ~, ~] = loadtracks(folders,relevant_track_fields);

save([SavePathName, filesep, SaveFileName], 'behavior_names', 'density', 'L', 'Tracks', 'xx', '-v7.3'); 