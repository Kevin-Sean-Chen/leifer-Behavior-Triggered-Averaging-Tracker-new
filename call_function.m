function success = call_function(input_string)
% calls the function with argument in the format function;argument
    try
        inputs = strsplit(input_string,';');
        script_name = inputs{1};
        folder_name = inputs{2};
        disp(script_name);
        disp(folder_name);
        %update the logs before starting
        update_logs(folder_name,script_name,'START','');
        
        function_handle = str2func(script_name);
        %run the function
        function_handle(folder_name);
        success = true;
        %update the logs after completing
        update_logs(folder_name,script_name,'COMPLETE','');
    catch ME
        success = false;
        %update the logs after completing
        update_logs(folder_name,script_name,'ERROR',ME.message);
    end
end