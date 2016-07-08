function success = AutoSave(curDir, autoSaveDir, copydata)
%AutoSave copies Tracks.mat, Parameters.txt and LEDVoltages.txt to the
%autoSaveDir under the corresponding date folder and subfolder
    if nargin < 3
        copydata = false;
    end
    
    ParentFolders = strsplit(curDir, '\');

    savePath = fullfile(autoSaveDir, ParentFolders(end-1), ParentFolders(end));
    
    savePath = savePath{1};
    try
        if copydata
            %copy the entire folder over
            %to save time, check if the directory already has the same
            %number of files
            if ~exist(savePath, 'dir')
                %the folder does not exist, make it
                copyfile(curDir,savePath)
            else
                %the folder exists
                savepath_filenum = length(dir([savePath, '\*.*']));
                curdir_filenum = length(dir([curDir, '\*.*']));
                
                if savepath_filenum == curdir_filenum
                    %there are the same number of files, update tracks.mat
                    %and individual videos
                    copyfile([curDir, '\', 'Tracks.mat'],savePath)
                    copyfile([curDir, '\individual_worm_imgs'],[savePath, '\individual_worm_imgs'])
                else
                    %there are different number of files, recopy everything
                    copyfile(curDir,savePath)
                end
            end
            
        else
            if ~exist(savePath, 'dir')
                mkdir(savePath)
            end
            copyfile([curDir, '\', 'Tracks.mat'],savePath)
            copyfile([curDir, '\', 'Parameters.txt'],savePath)
            copyfile([curDir, '\', 'LEDVoltages.txt'],savePath)    
            if exist([curDir, '\', 'tags.txt'], 'file')
                copyfile([curDir, '\', 'tags.txt'],savePath)
            end
        end
        success = 1;
    catch
        warning('no autosave occured');
        success = 0;
    end
end