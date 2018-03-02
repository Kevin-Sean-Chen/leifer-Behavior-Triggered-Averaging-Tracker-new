%not used in paper

percentile_threshold = 0.99;
fps = 14;
kernel_lengths = zeros(1,length(LNPStats));
kernels = [];
for LNP_index = 1:length(LNPStats)
    if LNPStats(LNP_index).BTA_percentile > percentile_threshold
        %BTA above percentile level, significant, find its kernel
        %length
        [current_kernel,kernel_lengths(LNP_index)] = BTA_to_kernel_old(LNPStats(LNP_index).BTA, ...
            LNPStats(LNP_index).trigger_count, meanLEDPower, stdLEDPower);
        kernels = [kernels;current_kernel];
    else
        kernels = [kernels;zeros(1,length(LNPStats(LNP_index).BTA))];
    end
end

kernel_lengths(kernel_lengths == 0) = []; % get rid of 0 time kernel lengths

kernel_lengths = kernel_lengths ./fps;

hist(kernel_lengths)
ax = gca;

ax.FontSize = 18;

%% plot all the kernels on top of each other
fps = 14;
BTA_seconds_before_and_after = 10;
BTA_seconds_before = BTA_seconds_before_and_after;
BTA_seconds_after = BTA_seconds_before_and_after;
NumTicks = 3;

figure
hold on

for LNP_index = 1:length(LNPStats)
    %shaded error bar represents the mean of the angular error
    plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, '-', 'Linewidth', 2);
end

meanLEDVoltageY = zeros(1,length(LNPStats(LNP_index).BTA));
meanLEDVoltageY(:) = meanLEDPower;
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
plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
xlabel(strcat(num2str(LNPStats(behavior_index).trigger_count), ' Events Analyzed')) % x-axis label
ylabel('Stimulus Intensity (uW/mm^2)') % y-axis label

%% illustrate how kernel cut off time works
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

