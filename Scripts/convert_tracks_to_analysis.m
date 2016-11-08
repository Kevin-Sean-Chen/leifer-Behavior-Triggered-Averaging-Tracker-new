[folders, ~] = getfoldersGUI();

for folder_index = 1:length(folders)
    folder_name = folders{folder_index}
    Tracks = load_single_folder(folder_name);
    savetracks(Tracks, folder_name);
    delete([folder_name, '\tracks.mat'])
end