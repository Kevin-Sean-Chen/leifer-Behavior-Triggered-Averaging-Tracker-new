function job_ID = get_job_ID(folder_name, script_name)
% update the logs on cluster
    try
        log_name = [folder_name,filesep,'status.csv'];
        [~, last_log_line] = system(['tail -n 1 ', log_name]);
        if isstrprop(last_log_line(end), 'cntrl'), last_log_line(end) = []; end
        log_fields = strsplit(last_log_line,',');
        if strcmp(log_fields{1},script_name) && strcmp(log_fields{1}, 'SUBMIT')
            %last log entry matches the current one and was just submitted
            job_ID = log_fields{5};
        else
            job_ID = 'MATLAB';
        end
    catch
        % dont let not logging screw with execution
        job_ID = 'MATLAB';
    end
end