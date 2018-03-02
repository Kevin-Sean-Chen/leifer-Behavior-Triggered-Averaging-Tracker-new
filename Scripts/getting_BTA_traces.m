%not used in paper

LEDPower = allTracks_GWN_noret(16).LEDPower;
for iteration = 1:1
    beginning_index = unidrnd(length(LEDPower)-281);
    end_index = beginning_index+280;
    stim_section = LEDPower(beginning_index:end_index);
    
    figure('Position', [400, 400, 400, 100])
    hold on
    %shaded error bar represents the mean of the angular error
    plot(-BTA_seconds_before:1/fps:BTA_seconds_after, fliplr(stim_section), '-r', 'Linewidth', 3);
    meanLEDVoltageY = zeros(1,length(LNPStats(behavior_index).BTA));
    meanLEDVoltageY(:) = meanLEDPower;
%     plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
    hold off
    axis([-10 10 0 18])
%     ax = gca;
%     ax.FontSize = 18;
%     xlabh = get(gca,'XLabel');
%     set(xlabh,'Position',get(xlabh,'Position') + [0 2.8 0])
%     limits = get(gca,'XLim');
%     set(gca,'XTick',linspace(limits(1),limits(2),NumTicks))
%     limits = get(gca,'YLim');
%     set(gca,'YTick',linspace(limits(1),limits(2),NumTicks))
    set(gca, 'XTick', [])
    set(gca, 'YTick', [])
end