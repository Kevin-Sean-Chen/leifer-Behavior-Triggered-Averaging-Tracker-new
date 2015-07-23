function success = AutoSave(curDir, autoSaveDir)
%AutoSave copies Tracks.mat, Parameters.txt and LEDVoltages.txt to the
%autoSaveDir under the corresponding date folder and subfolder
    ParentFolders = strsplit(curDir, '\');

    savePath = fullfile(autoSaveDir, ParentFolders(end-1), ParentFolders(end));
    
    savePath = savePath{1};
     try
        if ~exist(savePath, 'dir')
            mkdir(savePath)
        end
        copyfile('Tracks.mat',savePath)
        copyfile('Parameters.txt',savePath)
        copyfile('LEDVoltages.txt',savePath)     
        success = 1;
     catch
         success = 0;
     end
end