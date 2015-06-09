function []= AnalyzeGaussianCorrelationTime(folders, bin_size)
    fps = 14;
    
    %load the linear filter file
    [filename,pathname,~] = uigetfile('*.mat','Load Linear Kernel');
    load(fullfile(pathname,filename))
    %linear_kernel = linear_kernel - mean(linear_kernel);
    exp_fit_a = Experiments(length(Experiments)).exp_fit_a;
    exp_fit_b = Experiments(length(Experiments)).exp_fit_b;
    
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
    
    if nargin < 2 %no bin number specified
        bin_size = 1; %default bin size is one bin per frame
    end
    
    
%     reversalsByVoltage = struct('voltage', {}, 'reversal_counts', {}, 'frame_counts', {}, 'filtered_signal', {});
    
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        load('LEDVoltages.txt')
        
        %parameters = readtable('parameters.txt', 'Delimiter', '\t');
        %frames = parameters{1,{'FrameCount'}};
        %pulse_voltages = parameters{:,{'VoltageList'}};

        %get the reversal rate
        reversal_rate= ReversalRate(folders, bin_size);
        
        %get the filtered signal
        predicted_reversal_rate = PredictLNP(LEDVoltages, linear_kernel, exp_fit_a, exp_fit_b, bin_size);
        
        figure
        hold all
        plot(1/fps:1/fps:length(LEDVoltages)/fps,reversal_rate, 'DisplayName', 'Reversal Rate');
        plot(1/fps:1/fps:length(LEDVoltages)/fps,predicted_reversal_rate, 'DisplayName', 'Predicted Reversal Rate');
        hold off
        xlabel('time (s)') % x-axis label
        ylabel('reversal rate (reversals/worm/min)') % y-axis label
        legend('show');
        

        figure
        hold all
        plot(1/fps:1/fps:length(LEDVoltages)/fps,predicted_reversal_rate, 'DisplayName', 'Predicted Reversal Rate');
%         for wsize = fps*100%:fps:5*fps
%             plot(1/fps:1/fps:length(LEDVoltages)/fps,smoothts(reversal_rate,'g',wsize, wsize), 'DisplayName', ['Reversal Rate (smoothing window = ', num2str(wsize), ' frames)']);
%         end
        wsize = fps;
        plot(1/fps:1/fps:length(LEDVoltages)/fps,smoothts(reversal_rate,'b',wsize), 'DisplayName', ['Reversal Rate (smoothing window = ', num2str(wsize), ' frames)']);
        hold off
        xlabel('time (s)') % x-axis label
        ylabel('smoothed reversal rate (reversals/worm/min)') % y-axis label
        legend('show');
%         figure
%         hold on
%         plot(cumsum(reversal_rate), 'r', 'DisplayName', 'Reversal Rate');
%         plot(cumsum(predicted_reversal_rate), 'b', 'DisplayName', 'Predicted Reversal Rate');
%         hold off
%         xlabel('time') % x-axis label
%         ylabel('reversals') % y-axis label
%         legend('show');
    end
    
end