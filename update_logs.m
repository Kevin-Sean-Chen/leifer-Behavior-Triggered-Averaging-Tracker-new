function log_entry = update_logs(folder_name, script_name, status, job_ID, comment)
% update the logs on cluster

    try
        master_log_name = '/tigress/LEIFER/Mochi/logs/masterlog.csv';
        error_log_name = '/tigress/LEIFER/Mochi/logs/errorlog.csv';
        log_name = [folder_name,filesep,'status.csv'];

        current_time = datestr(datetime('now'),'yyyy-mm-dd_HH:MM:ss');
        [~,hostname] = system('hostname');
        hostname = hostname(1:end-1);

        log_entry = [script_name,',',status,',',current_time,',',folder_name,',',...
            job_ID,',',hostname,',',comment];
        write_log(log_name, log_entry);   

        if ~ispc
            %don't update master logs on PC
            write_log(master_log_name, log_entry);
            if strcmp(status, 'ERROR')
                write_log(error_log_name, log_entry);
            end
        end
    catch
        % dont let not logging screw with execution
    end
end