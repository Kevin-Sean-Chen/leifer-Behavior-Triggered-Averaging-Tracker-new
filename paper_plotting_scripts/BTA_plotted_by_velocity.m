load('reference_embedding.mat')
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_behaviors_reordered_20171030.mat')
behavior_colors = [[255,238,238]; [255,189,189]; [255,123,123]; [255,74,74]; [255,16,16]; [255,0,0]; [230,230,255]; [65,65,255]; [255,0,255]] ./ 255; %based on centroid velocity
fps = 14;
BTA_seconds_before_and_after = 10;
NumTicks = 3;

BTA_seconds_before = BTA_seconds_before_and_after;
BTA_seconds_after = BTA_seconds_before_and_after;
    
%plot the kernels one on top of another color coded by velocity
LNPStats = LNPStats_nondirectional_ret;
meanLEDPower = meanLEDPower_nondirectional_ret;
figure

for behavior_index = 1:length(LNPStats)
    hold on
    %shaded error bar represents the mean of the angular error
    plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(behavior_index).BTA, '-', 'color', behavior_colors(behavior_index,:), 'Linewidth', 3,'DisplayName',[behavior_names{behavior_index}, ' (n=', num2str(LNPStats(behavior_index).trigger_count),')']);
%             xlabel(strcat('Time (s) (', num2str(LNPStats(behavior_index).trigger_count), ' behaviors analyzed)')) % x-axis label
end

% meanLEDVoltageY = zeros(1,length(LNPStats(behavior_index).BTA));
%     meanLEDVoltageY(:) = meanLEDPower;
% plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
    hold off
xlabel('Time (s)') % x-axis label
%             ylabel('Stimulus Intensity (uW/mm^2)') % y-axis label 
axis([-10 10 23 27])
%axis([-10 2 0 5])
ax = gca;
%ax.XTick = ;
%             ax.YTick = linspace(0.64,0.84,5);
ax.FontSize = 18;
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') + [0 5.5 0])
limits = get(gca,'XLim');
set(gca,'XTick',linspace(limits(1),limits(2),NumTicks))
limits = get(gca,'YLim');
set(gca,'YTick',linspace(limits(1),limits(2),NumTicks))
legend('show')