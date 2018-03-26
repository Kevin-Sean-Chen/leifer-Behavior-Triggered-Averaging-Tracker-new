load('reference_embedding.mat')

relevant_track_fields = {'BehavioralTransition','Embeddings','Frames','LEDPower','Path'};    

%select folders
folders = getfoldersGUI();
[SaveFileName,SavePathName] = uiputfile('*.mat','Save tracks file name');

%load tracks
[Tracks, ~, ~] = loadtracks(folders,relevant_track_fields);

save([SavePathName, filesep, SaveFileName], 'behavior_names', 'density', 'L', 'Tracks', 'xx', '-v7.3'); 

%% load tracks from a remote directory and copy them into a local directory
relevant_track_fields = {'BehavioralTransition','Embeddings','Frames','LEDPower','LEDVoltages','LEDVoltage2Power','Path','Centerlines','Speed','Velocity','ProjectedEigenValues','Spectra'};    

source_folders = getfoldersGUI();
destination_folder = uigetdir('', 'Select Destination Folder');

for folder_index = 1:length(source_folders)
	%loop through every source folder and for each, save the tracks into source folders
	[Tracks, ~, ~] = loadtracks(source_folders{folder_index},relevant_track_fields);
    source_path = strsplit(source_folders{folder_index},filesep);
    experiment_folder = source_path{length(source_path)};
    date_folder = source_path{length(source_path)-1};
    destination_path = [destination_folder, filesep, date_folder, filesep, experiment_folder];

    savetracks(Tracks, destination_path, true); % save the tracks to destination
    folder_index
end

%clean up
for folder_index = 1:length(source_folders)
	%loop through every source folder and for each, save the tracks into source folders
    source_path = strsplit(source_folders{folder_index},filesep);
    experiment_folder = source_path{length(source_path)};
    date_folder = source_path{length(source_path)-1};
    destination_path = [destination_folder, filesep, date_folder, filesep, experiment_folder];
%     try
%         rmdir([destination_path, filesep, 'individual_worm_imgs'], 's') %remove the indiviudal files folder
%     catch
%     end
%     try
%         delete([destination_path, filesep, 'status.csv']);
%     catch
%     end
%     try
%         delete([destination_path, filesep, 'processed.avi']);
%     catch
%     end
    try
        delete([destination_path, filesep, 'analysis', filesep, 'Spectra.mat']);
    catch
    end    
    folder_index
end
