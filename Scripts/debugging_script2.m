figure
hold on
%shaded error bar represents the mean of the angular error
shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, fliplr(kernels(behavior_index,:))+meanLEDPower, 2*stdLEDPower*sqrt(2/LNPStats(behavior_index).trigger_count)*ones(1,length(LNPStats(behavior_index).BTA)), {'-k', 'Linewidth', 3});
%shadedErrorBar(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(behavior_index).BTA, 2*stdLEDPower*sqrt(2/LNPStats(behavior_index).trigger_count)*ones(1,length(LNPStats(behavior_index).BTA)), {'-k', 'Linewidth', 3});
meanLEDVoltageY = zeros(1,length(LNPStats(behavior_index).BTA));
meanLEDVoltageY(:) = meanLEDPower;
plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
hold off
%             xlabel(strcat('Time (s) (', num2str(LNPStats(behavior_index).trigger_count), ' behaviors analyzed)')) % x-axis label
xlabel(strcat(num2str(LNPStats(behavior_index).trigger_count), ' Events Analyzed')) % x-axis label
%             ylabel('Stimulus Intensity (uW/mm^2)') % y-axis label
axis([-10 10 8 10])
%axis([-10 2 0 5])
ax = gca;
%ax.XTick = ;
%             ax.YTick = linspace(0.64,0.84,5);
ax.FontSize = 18;
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') + [0 2.8 0])
limits = get(gca,'XLim');
set(gca,'XTick',linspace(limits(1),limits(2),NumTicks))
limits = get(gca,'YLim');
set(gca,'YTick',linspace(limits(1),limits(2),NumTicks))
