function success = call_function(input_string)
% calls the function in this folder with argument in the format function;argument
% and update the appropriate logs

    try
        inputs = strsplit(input_string,';');
        script_name = inputs{1};
        folder_name = inputs{2};
        job_ID = get_job_ID(folder_name, script_name);
        disp(script_name);
        disp(folder_name);
        disp(job_ID);
        %update the logs before starting
        update_logs(folder_name,script_name,'RUNNING',job_ID,'Within_MATLAB');
        
        function_handle = str2func(script_name);
        %run the function
%         profile on
        function_handle(folder_name);
%         profile off
%         profsave(profile('info'),folder_name)
        success = true;
        %update the logs after completing
        update_logs(folder_name,script_name,'COMPLETE',job_ID,'Within_MATLAB');
    catch ME
        success = false;
        %update the logs after completing
        update_logs(folder_name,script_name,'ERROR',job_ID,regexprep(ME.message,'\r\n|\n|\r',' '));
    end
end