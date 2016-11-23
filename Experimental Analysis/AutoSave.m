function success = AutoSave(folder_name, copydata)
%AutoSave copies Tracks.mat, Parameters.txt and LEDVoltages.txt and the analysis folder to the
%autoSaveDir under the corresponding date folder and subfolder
    if nargin < 2
        copydata = false;
    end
    
    parameters = load_parameters(folder_name); %load experiment parameters
    autoSaveDir = parameters.DefaultPath;
    
    ParentFolders = strsplit(folder_name, '\');
    savePath = fullfile(autoSaveDir, ParentFolders(end-1), ParentFolders(end));
    
    savePath = savePath{1};
    try
        if copydata
            %copy the entire folder over
            %to save time, check if the directory already has the same
            %number of files
            if ~exist(savePath, 'dir')
                %the folder does not exist, make it
                copyfile(folder_name,savePath)
            else
                %the folder exists
                savepath_filenum = length(dir([savePath, '\*.*']));
                curdir_filenum = length(dir([folder_name, '\*.*']));
                
                if savepath_filenum == curdir_filenum
                    %there are the same number of files, update tracks.mat
                    %and individual videos
                    copyfile([folder_name, '\', 'tracks.mat'],savePath)
                    copyfile([folder_name, '\individual_worm_imgs'],[savePath, '\individual_worm_imgs'])
                    copyfile([folder_name, '\analysis'],[savePath, '\analysis'])
                else
                    %there are different number of files, recopy everything
                    copyfile(folder_name,savePath)
                end
            end
            
        else
            if ~exist(savePath, 'dir')
                mkdir(savePath)
            end
            copyfile([folder_name, '\', 'Parameters.txt'],savePath)
            copyfile([folder_name, '\', 'LEDVoltages.txt'],savePath)    
            if exist([folder_name, '\', 'tracks.txt'], 'file')
                copyfile([folder_name, '\', 'tracks.mat'],savePath)
            end            
            if exist([folder_name, '\', 'tags.txt'], 'file')
                copyfile([folder_name, '\', 'tags.txt'],savePath)
            end
            if exist([folder_name, '\analysis'], 'dir')
                copyfile([folder_name, '\analysis'],[savePath, '\analysis'])
            end
        end
        success = true;
    catch
        warning('no autosave occured');
        success = false;
    end
end