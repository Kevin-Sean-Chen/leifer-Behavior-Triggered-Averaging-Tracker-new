function []= AnalyzeTriangleWave(folders)
    fps = 14;
    bin_size = 14;
    analyze_seconds_before = 5-(1/fps);
    analyze_seconds_after = 60;
    
    %load the linear filter file
    [filename,pathname,~] = uigetfile('*.mat','Load Linear Kernel');
    load(fullfile(pathname,filename))
    
    if nargin < 1 %no folders are given, ask user to select
        folders = {};
        while true
            folder_name = uigetdir
            if folder_name == 0
                break
            else
                folders{length(folders)+1} = folder_name;
            end
        end
    end
    
    reversalsByVoltage = struct('voltage', {}, 'reversal_counts', {}, 'frame_counts', {}, 'filtered_signal', {});
    
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        load('LEDVoltages.txt')
        
        parameters = readtable('parameters.txt', 'Delimiter', '\t');
        %frames = parameters{1,{'FrameCount'}};
        minVoltage = min(LEDVoltages);
        maxVoltage = parameters{1,{'maxVoltage'}};
        %get the reversal rate
        [~, reversal_counts, frame_counts]= ReversalRate(folders, 1);
        
        %get the filtered signal
        filtered_signal = conv(LEDVoltages, linear_kernel);
        filtered_signal = filtered_signal(1:length(LEDVoltages)); %cut off the tail

%         changes_in_voltage = [0, 0, diff(LEDVoltages,2)]; %find where the voltages turns around (change in 2nd derivative)

        repeat_voltage_locations = find(LEDVoltages==minVoltage);
        
        %remove the sections that cannot be analyzed
        repeat_voltage_locations = repeat_voltage_locations(repeat_voltage_locations > analyze_seconds_before*fps);
        repeat_voltage_locations = repeat_voltage_locations(repeat_voltage_locations < length(filtered_signal) - analyze_seconds_after*fps);

        if ~isempty(repeat_voltage_locations)
            if isempty(find([reversalsByVoltage.voltage] == maxVoltage, 1))
                %no entry with this max voltage before, create it
                reversalsByVoltageIndex = length(reversalsByVoltage) + 1;
                reversalsByVoltage(reversalsByVoltageIndex).voltage = maxVoltage;
                %the filtered signal, use the first occurance
                reversalsByVoltage(reversalsByVoltageIndex).filtered_signal = filtered_signal(repeat_voltage_locations(1) - analyze_seconds_before*fps:repeat_voltage_locations(1) + analyze_seconds_after*fps);
                reversalsByVoltage(reversalsByVoltageIndex).reversal_counts = zeros(1, (analyze_seconds_before+analyze_seconds_after)*fps+1);
                reversalsByVoltage(reversalsByVoltageIndex).frame_counts = zeros(1, (analyze_seconds_before+analyze_seconds_after)*fps+1);
            else
                reversalsByVoltageIndex = find([reversalsByVoltage.voltage] == maxVoltage);
            end

            for repeat_voltage_location_index = 1:length(repeat_voltage_locations)
                repeat_voltage_location = repeat_voltage_locations(repeat_voltage_location_index);
                this_repeat_reversal_counts = reversal_counts(repeat_voltage_location - analyze_seconds_before*fps:repeat_voltage_location + analyze_seconds_after*fps);
                this_repeat_frame_counts = frame_counts(repeat_voltage_location - analyze_seconds_before*fps:repeat_voltage_location + analyze_seconds_after*fps);
                reversalsByVoltage(reversalsByVoltageIndex).reversal_counts = reversalsByVoltage(reversalsByVoltageIndex).reversal_counts + this_repeat_reversal_counts;
                reversalsByVoltage(reversalsByVoltageIndex).frame_counts = reversalsByVoltage(reversalsByVoltageIndex).frame_counts + this_repeat_frame_counts;                
            end
        end
    end
    
    reversalsByVoltage = nestedSortStruct(reversalsByVoltage, 'voltage'); %sort it

    mymarkers = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
    mycolors = jet(length(reversalsByVoltage));
    
    subplot(1,2,1);
    hold on;
    
    for voltage_index = 1:length(reversalsByVoltage)
        binned_reversals = sum(reshape(reversalsByVoltage(voltage_index).reversal_counts, [], (analyze_seconds_before+analyze_seconds_after+(1/fps))*fps/bin_size),1)';
        binned_framecounts = sum(reshape(reversalsByVoltage(voltage_index).frame_counts, [], (analyze_seconds_before+analyze_seconds_after+(1/fps))*fps/bin_size),1)';
        plot(-analyze_seconds_before:bin_size/fps:analyze_seconds_after, binned_reversals./binned_framecounts, 'color', mycolors(voltage_index,:), 'marker', mymarkers{mod(voltage_index,numel(mymarkers))+1}, 'DisplayName', strcat(num2str(reversalsByVoltage(voltage_index).voltage*0.13756+0.000378), ' mW/mm^2 (', num2str(sum(reversalsByVoltage(voltage_index).reversal_counts)), ' reversals analyzed)'));
    end


    xlabel(strcat('time in seconds (pulse at 0) (', num2str(sum([reversalsByVoltage.reversal_counts])), ' reversals analyzed)')) % x-axis label
    ylabel('reversal probability') % y-axis label
    legend('show');
    hold off;
    
    subplot(1,2,2);
    hold on;
    for voltage_index = 1:length(reversalsByVoltage)
        plot(-analyze_seconds_before:1/fps:analyze_seconds_after, reversalsByVoltage(voltage_index).filtered_signal, 'color', mycolors(voltage_index,:), 'marker', mymarkers{mod(voltage_index,numel(mymarkers))+1}, 'DisplayName', strcat(num2str(reversalsByVoltage(voltage_index).voltage*0.13756+0.000378), ' mW/mm^2'))
    end


    xlabel(strcat('time in seconds (pulse at 0)')) % x-axis label
    ylabel('filtered signal') % y-axis label
    legend('show');
    hold off;
end