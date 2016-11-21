function [] = deletetracks(folder_name)
%delete the tracks given folders
    folder_name

    deletePath = [folder_name, filesep, 'analysis'];
    if exist(deletePath, 'dir')
        %delete the previous track variables by deleting the analysis
        %folder
        delete([deletePath, filesep, '*.*']);
    end
end

