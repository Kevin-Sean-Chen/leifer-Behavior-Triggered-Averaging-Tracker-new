folders = {};
folder_count = 0;
while true
    folder_name = uigetdir
    if folder_name == 0
        break
    else
        folder_count = folder_count + 1;
        folders{folder_count} = folder_name;
    end
end
for folder_index = 1:folder_count
    folder_name = folders{folder_index};
    cd(folder_name) %open the directory of image sequence
    allFiles = dir(); %get all the tif files
    for file_index = 1:length(allFiles)
        if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
            strcat(folder_name, '\', allFiles(file_index).name)
             %ProcessImageDirectory(strcat(folder_name, '\', allFiles(file_index).name), 1, 1, 'continue');
            ProcessImageDirectory(strcat(folder_name, '\', allFiles(file_index).name), 0, 1, 'analysis');
            file_index/length(allFiles)
        end
    end
end

