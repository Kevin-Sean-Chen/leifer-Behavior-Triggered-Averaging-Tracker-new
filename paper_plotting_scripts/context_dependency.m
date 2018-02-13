load('reference_embedding.mat')
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_behaviors_reordered_20171030.mat')

LNPStats = LNPStats_directional_ret;
meanLEDPower = meanLEDPower_directional_ret;
fps = 14;
number_of_behaviors = max(L(:))-1;
BTA_seconds_before_and_after = 10;
BTA_seconds_before = BTA_seconds_before_and_after;
BTA_seconds_after = BTA_seconds_before_and_after;
NumTicks = 3;
folders_platetap = getfoldersGUI();
folders_optotap = getfoldersGUI();


%% plot the forward locomotion series
behavior_sequence_to_plot = 1:6;
number_of_plots = length(behavior_sequence_to_plot)-1;
all_edge_pairs = get_edge_pairs(number_of_behaviors);
figure
for transition_index = 1:number_of_plots
    % plot going left
    behavior_from = behavior_sequence_to_plot(transition_index);
    behavior_to = behavior_sequence_to_plot(transition_index+1);
    
    %find the behavior index
    LNPStats_indecies = zeros(1,2);
	[~, LNPStats_indecies(1)] = ismember([behavior_from, behavior_to],all_edge_pairs,'rows');
	[~, LNPStats_indecies(2)] = ismember([behavior_to, behavior_from],all_edge_pairs,'rows');
    
    for row_index = 1:2
        LNP_index = LNPStats_indecies(row_index);
        behavior_to = all_edge_pairs(LNP_index,2);
        behavior_color = behavior_colors(behavior_to,:);
        subplot(3,number_of_plots,(row_index-1)*number_of_plots+transition_index)
        hold on
        if LNPStats(LNP_index).BTA_percentile > 0.99
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, '-', 'color',behavior_color, 'Linewidth', 3);
        else
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, ':', 'color',behavior_color, 'Linewidth', 3);
        end
%         meanLEDVoltageY = zeros(1,length(LNPStats(LNP_index).BTA));
%         meanLEDVoltageY(:) = meanLEDPower;
%         plot(-BTA_seconds_before:1/fps:BTA_seconds_after, meanLEDVoltageY, 'r', 'Linewidth', 3)
        hold off
        xlabel(['n=',num2str(LNPStats(LNP_index).trigger_count)]) % x-axis label
        axis([-10 10 23 27])
        %axis([-10 2 0 5])
        ax = gca;
        %ax.XTick = ;
    %             ax.YTick = linspace(0.64,0.84,5);
        ax.FontSize = 18;
        xlabh = get(gca,'XLabel');
        set(xlabh,'Position',get(xlabh,'Position') + [0 1.6 0])
        set(gca,'XTick','')
        set(gca,'YTick','')
    end
end

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
            axis([-10 10 23 27])
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

%% all 72 context dependent transitions differences for plate tap experiments in a grid
all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_tap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_tap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
tap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
tap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

mean_control_tap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_control_tap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
control_tap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
control_tap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

tap_difference_significant = false(number_of_behaviors, number_of_behaviors);
tap_pvalue = zeros(number_of_behaviors, number_of_behaviors);
tap_hypothesis_counts = 0;
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [mean_tap_transition_rates(behavior_from,behavior_to),mean_control_tap_transition_rates(behavior_from,behavior_to), ...
                std_tap_transition_rates(behavior_from,behavior_to),std_control_tap_transition_rates(behavior_from,behavior_to), ...
                tap_difference_significant(behavior_from,behavior_to),tap_pvalue(behavior_from,behavior_to), ...
                tap_transitions_counts(behavior_from,behavior_to),control_tap_transitions_counts(behavior_from,behavior_to),...
                tap_observation_counts(behavior_from,behavior_to),control_tap_observation_counts(behavior_from,behavior_to)] = ...
                average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to);
             tap_hypothesis_counts = tap_hypothesis_counts + 1;
        end
    end
end
%multiple hypothesis testing correction of significance
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            tap_difference_significant(behavior_from,behavior_to) = 0.05./tap_hypothesis_counts > tap_pvalue(behavior_from,behavior_to);
        end
    end
end
%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            subplot(double(number_of_behaviors),double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
            barwitherr([std_control_tap_transition_rates(behavior_from,behavior_to); std_tap_transition_rates(behavior_from,behavior_to)], [mean_control_tap_transition_rates(behavior_from,behavior_to); mean_tap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
            ax = gca;
            if tap_difference_significant(behavior_from,behavior_to)
                sigstar({[1,2]},0.05);
%                 ax.XColor = 'red';
%                 ax.YColor = 'red';
%                 title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'r')
%             else
%                 title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
%                 sigstar({[1,2]},nan,0,30);           
            end
%             if behavior_from == 2 && behavior_to == 1
%                 ylabel('Platetap Transition Rate (transitions/min)')
% %                 set(gca,'XTickLabel',{'-','+'})
% %             else
% %                 set(gca,'YTick','')
%             end

            box('off')
%             title(['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
            title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
            set(gca,'XTick','')
            set(gca,'fontsize',14)
            y_limits = ylim;             %get y lim
            axis([0 3 0 ceil(y_limits(2))]);
            ax.YTick = linspace(0,ceil(y_limits(2)),2);
        end
    end
end


%% all 72 context dependent transitions differences for optotap experiments in a grid
all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
optotap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
optotap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

mean_control_optotap_transition_rates = zeros(number_of_behaviors, number_of_behaviors);
std_control_optotap_transition_rates =  zeros(number_of_behaviors, number_of_behaviors);
control_optotap_transitions_counts = zeros(number_of_behaviors, number_of_behaviors);
control_optotap_observation_counts = zeros(number_of_behaviors, number_of_behaviors);

optotap_difference_significant = false(number_of_behaviors, number_of_behaviors);
optotap_pvalue = zeros(number_of_behaviors, number_of_behaviors);
control_hypothesis_counts = 0;
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            [mean_optotap_transition_rates(behavior_from,behavior_to),mean_control_optotap_transition_rates(behavior_from,behavior_to), ...
                std_optotap_transition_rates(behavior_from,behavior_to),std_control_optotap_transition_rates(behavior_from,behavior_to), ...
                optotap_difference_significant(behavior_from,behavior_to),optotap_pvalue(behavior_from,behavior_to), ...
                optotap_transitions_counts(behavior_from,behavior_to),control_optotap_transitions_counts(behavior_from,behavior_to),...
                optotap_observation_counts(behavior_from,behavior_to),control_optotap_observation_counts(behavior_from,behavior_to)] = ...
                average_transition_rate_after_tap(folders_optotap, behavior_from, behavior_to);
             control_hypothesis_counts = control_hypothesis_counts + 1;
        end
    end
end
%multiple hypothesis testing correction of significance
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            optotap_difference_significant(behavior_from,behavior_to) = 0.05./control_hypothesis_counts > optotap_pvalue(behavior_from,behavior_to);
        end
    end
end

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            if control_optotap_transitions_counts(behavior_from,behavior_to) == 0 && optotap_transitions_counts(behavior_from,behavior_to) == 0
            else
                subplot(double(number_of_behaviors),double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
                barwitherr([std_control_optotap_transition_rates(behavior_from,behavior_to); std_optotap_transition_rates(behavior_from,behavior_to)], [mean_control_optotap_transition_rates(behavior_from,behavior_to); mean_optotap_transition_rates(behavior_from,behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
                ax = gca;
                if optotap_difference_significant(behavior_from,behavior_to)
                    sigstar({[1,2]},0.05);
    %                 ax.XColor = 'red';
    %                 ax.YColor = 'red';
    %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'r')
    %             else
    %                 title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
    %                 sigstar({[1,2]},nan,0,30);           
                end
    %             set(gca,'XTickLabel',{['n=',num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=', num2str(optotap_pvalue(behavior_from,behavior_to))]})
    %             if behavior_from == 2 && behavior_to == 1
    %                 ylabel('Platetap Transition Rate (transitions/min)')
    % %             else
    % %                 set(gca,'YTick','')
    %             end
                title(['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
    %             title({['n=', num2str(control_optotap_transitions_counts(behavior_from,behavior_to)),', ',num2str(optotap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(optotap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
                box('off')
                set(gca,'XTick','')
                set(gca,'fontsize',14)
                y_limits = ylim;             %get y lim
                axis([0 3 0 ceil(y_limits(2))]);
                ax.YTick = linspace(0,ceil(y_limits(2)),2);
            end
        end
    end
end
