%not used in paper

[folders, ~] = getfoldersGUI();

for folder_index = 1:length(folders)
    folder_name = folders{folder_index}
    if exist([folder_name, '\tracks.mat'], 'file')
        Tracks = load_single_folder(folder_name);
        savetracks(Tracks, folder_name);
        delete([folder_name, '\tracks.mat'])
    end
end