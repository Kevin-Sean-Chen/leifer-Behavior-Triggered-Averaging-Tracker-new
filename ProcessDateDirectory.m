folder_name = uigetdir
cd(folder_name) %open the directory of image sequence
allFiles = dir(); %get all the tif files
for file_index = 1:length(allFiles)
    if allFiles(file_index).isdir && ~strcmp(allFiles(file_index).name, '.') && ~strcmp(allFiles(file_index).name, '..')
        ProcessImageDirectory(strcat(folder_name, '\', allFiles(file_index).name), 1);
        file_index/length(allFiles)
    end
end 

