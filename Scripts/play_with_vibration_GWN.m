%% load Tracks
relevant_track_fields = {'BehavioralTransition','Frames','PWM','LEDVoltage2Power'};    

%select folders
%folders_vibration_GWN = getfoldersGUI();
% folders_tri_ret = getfoldersGUI();

%ret
[allTracks, folder_indecies, track_indecies] = loadtracks(folders_vibration_GWN,relevant_track_fields);

load('reference_embedding.mat')
number_of_behaviors = max(L(:))-1;


%get LNPs
[LNPStats_nondirectional_ret, meanLEDPower_nondirectional_ret, stdLEDPower_nondirectional_ret] = FitLNP_vibrations(allTracks,folder_indecies,folders_vibration_GWN);
[LNPStats_directional_ret, meanLEDPower_directional_ret, stdLEDPower_directional_ret] = directional_FitLNP_vibrations(allTracks,folder_indecies,folders_vibration_GWN);

PlotBehavioralMappingExperimentGroup(LNPStats_nondirectional_ret, meanLEDPower_nondirectional_ret, stdLEDPower_nondirectional_ret, L, density, xx)
% PlotDirectionalBehavioralMappingExperimentGroup(LNPStats_directional_ret, meanLEDPower_directional_ret, stdLEDPower_directional_ret, L, density, xx)

meanLEDPower = meanLEDPower_directional_ret;
LNPStats = LNPStats_directional_ret;
%% all 72 context dependent transitions kernels in a grid
all_edge_pairs = get_edge_pairs(number_of_behaviors);
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            %find the behavior index
            [~, LNP_index] = ismember([behavior_from, behavior_to],all_edge_pairs,'rows');

            behavior_color = behavior_colors(behavior_to,:);
            subplot(double(number_of_behaviors),double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
            hold on
            if LNPStats(LNP_index).BTA_percentile > 0.99
                plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, '-', 'color',behavior_color, 'Linewidth', 3);
            else
                plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, '-', 'color',[0.9, 0.9, 0.9], 'Linewidth', 3);
            end

            meanLEDVoltageY = zeros(1,length(LNPStats(LNP_index).BTA));
            meanLEDVoltageY(:) = meanLEDPower;
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, '--', 'color', [0.4 0.4 0.4], 'Linewidth', 2,'DisplayName','zero');
            hold off
            xlabel(['n=',num2str(LNPStats(LNP_index).trigger_count)]) % x-axis label
            axis([-10 10 4 6])
            %axis([-10 2 0 5])
            ax = gca;
            %ax.XTick = ;
        %             ax.YTick = linspace(0.64,0.84,5);
            ax.FontSize = 10;
            ax.Clipping = 'off';
            xlabh = get(gca,'XLabel');
            %set(xlabh,'Position',get(xlabh,'Position') + [0 1.6 0])
            set(gca,'XTick','')
            set(gca,'YTick','')
        end
    end
end
