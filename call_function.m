function success = call_function(input_string)
% calls the function with argument in the format function;argument
    try
        inputs = strsplit(input_string,';');
        script_name = inputs{1};
        folder_name = inputs{2};
        job_ID = get_job_ID(folder_name);
        disp(script_name);
        disp(folder_name);
        disp(job_ID);
        %update the logs before starting
        update_logs(folder_name,script_name,'START',job_ID,'');
        
        function_handle = str2func(script_name);
        %run the function
        function_handle(folder_name);
        success = true;
        %update the logs after completing
        update_logs(folder_name,script_name,'COMPLETE',job_ID,'');
    catch ME
        success = false;
        %update the logs after completing
        update_logs(folder_name,script_name,'ERROR',job_ID,regexprep(ME.message,'\r\n|\n|\r',' '));
    end
end