function [] = write_log(log_file, log_entry)
% write to a specific log file

    if ~exist(log_file, 'file')
        fileID = fopen(log_file,'w');
        fwrite(fileID,['Script_Name,Status,Time,Folder_Name,JobID,Computer_Name,Comment', char(10)]);
    else
        fileID = fopen(log_file,'a');
    end
    
    fwrite(fileID,[log_entry, char(10)]);
    fclose(fileID);
end