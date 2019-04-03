function [ time, voltages, trigger_point ] = read_oscilloscope_folder( folder_name )
    %reads the oscilloscope outputs
    
    if nargin < 1
        folder_name = uigetdir
    end
    [~,folder_number,~] = fileparts(folder_name);
    folder_number = folder_number(4:end); %ex: 0000
    csv_filename = [folder_name, filesep, 'F', folder_number, 'CH1.CSV'];
    csv_values = readtable(csv_filename, 'Delimiter', ',');
    
    time = table2array(csv_values(:,4));
    voltages = table2array(csv_values(:,5));
    trigger_point = str2double(csv_values{3,2});
%     figure
%     hold on
%     plot(time, voltages, 'b-')
%     plot(time(trigger_point), voltages(trigger_point), 'ro')
    
end

