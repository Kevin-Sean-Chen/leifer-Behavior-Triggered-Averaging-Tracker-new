% relevant_track_fields = {'Eccentricity','Direction','Speed','Size'};
% 
% %% Load tracks
% Tracks = load_single_folder(folder_name, relevant_track_fields);
tic
find_centerlines(folder_name)
toc