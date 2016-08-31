for folder_index = 1:length(folders)
    folder_name = folders{folder_index};
    folders{folder_index} = ['F', folder_name(2:end)];
end