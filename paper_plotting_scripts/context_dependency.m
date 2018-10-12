load('reference_embedding.mat')
%load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_behaviors_reordered_20171030.mat')
% LNPStats = LNPStats_directional_ret;
% meanLEDPower = meanLEDPower_directional_ret;
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\AML67\behavior_map_no_subsampling\Embedding_LNPFit\LNPfit_noret_20180316.mat')
LNPStats = LNPStats_directional;
meanLEDPower = meanLEDPower_directional;

fps = 14;
number_of_behaviors = max(L(:))-1;
BTA_seconds_before_and_after = 10;
BTA_seconds_before = BTA_seconds_before_and_after;
BTA_seconds_after = BTA_seconds_before_and_after;
NumTicks = 3;
folders_platetap = getfoldersGUI();
folders_optotap = getfoldersGUI();
rows_per_page = 9;
bootstrap_n = 100;


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
bootstrap_fractional_increases = cell(number_of_behaviors, number_of_behaviors);

tap_difference_significant = false(number_of_behaviors, number_of_behaviors);
tap_pvalue = eye(number_of_behaviors);
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
            
            %bootstrap values for fractional increase from baseline after stim
            stim_sample_count = tap_observation_counts(behavior_from,behavior_to)/29; % 29 is 2 seconds
            control_sample_count = control_tap_observation_counts(behavior_from,behavior_to)/29;
            stim_samples = false(1,stim_sample_count);
            stim_samples(1:tap_transitions_counts(behavior_from,behavior_to)) = true;            
            control_samples = false(1,control_sample_count);
            control_samples(1:control_tap_transitions_counts(behavior_from,behavior_to)) = true;
            bootstrap_frac_inc = zeros(1,bootstrap_n);
            for bootstrap_index = 1:bootstrap_n
                bootstrap_stim_sample = datasample(stim_samples,stim_sample_count);
                bootstrap_control_sample = datasample(control_samples,stim_sample_count);
                if any(bootstrap_control_sample)
                    bootstrap_frac_inc(bootstrap_index) = (sum(bootstrap_stim_sample)/stim_sample_count) / (sum(bootstrap_control_sample)/control_sample_count);
                end
            end
            bootstrap_fractional_increases{behavior_from,behavior_to} = bootstrap_frac_inc;
            
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


%plot reversal fractioal increase from bootstrapping
behavior_to = 3;
turn_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{2,behavior_to});
turn_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{2,behavior_to});

fwd_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{1,behavior_to});
fwd_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{1,behavior_to});

%get p value using 2 tails
bootstrap_frac_inc_diff = bootstrap_fractional_increases{1,behavior_to} - bootstrap_fractional_increases{2,behavior_to};
bootstrap_frac_inc_diff_mean_offset_abs = abs(bootstrap_frac_inc_diff - mean(bootstrap_frac_inc_diff));
mean_distance = abs(turn_bootstrap_frac_inc_mean - fwd_bootstrap_frac_inc_mean);
p = sum(bootstrap_frac_inc_diff_mean_offset_abs > mean_distance) ./ length(bootstrap_frac_inc_diff_mean_offset_abs); %find the fraction of points with larger difference when the null is true

figure('pos',[10 10 200 300])
barwitherr([fwd_bootstrap_frac_inc_std; turn_bootstrap_frac_inc_std], [fwd_bootstrap_frac_inc_mean; turn_bootstrap_frac_inc_mean],'FaceColor',behavior_colors(behavior_to,:))
ax = gca;
if p < 0.05
    sigstar({[1,2]},p);
end
box('off')
set(gca,'YTick',[0 10])
set(gca,'XTickLabel',{'Fwd','Turn'})
set(gca,'fontsize',14)
ylabel('Times More Likely to Reverse with Stim')
title(['p=', num2str(p)])
axis([0 3 0 10]);

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            if control_tap_transitions_counts(behavior_from,behavior_to) == 0 && tap_transitions_counts(behavior_from,behavior_to) == 0
            else
                scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
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

                title(['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],'Color', 'k', 'FontWeight', 'normal', 'Fontsize', 14)
                %title({['n=', num2str(control_tap_transitions_counts(behavior_from,behavior_to)),', ',num2str(tap_transitions_counts(behavior_from,behavior_to))],['p=',num2str(round(tap_pvalue(behavior_from,behavior_to),2,'significant'))]},'Color', 'k')
                box('off')
                set(gca,'XTick','')
                set(gca,'fontsize',14)
                y_limits = ylim;             %get y lim
                new_ylim = y_limits(2);
%                new_ylim = 2;
                if new_ylim > 1
                    new_ylim = ceil(y_limits(2));
                else
                    new_ylim = 1;
                end
                axis([0 3 0 new_ylim]);
                if (behavior_from == 9 && behavior_to == 1) || new_ylim > 1
                    ax.YTick = linspace(0,new_ylim,2);
                else
                    set(gca,'YTick','')
                end
            end
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
bootstrap_fractional_increases = cell(number_of_behaviors, number_of_behaviors);

optotap_difference_significant = false(number_of_behaviors, number_of_behaviors);
optotap_pvalue = eye(number_of_behaviors);
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
            
            %bootstrap values for fractional increase from baseline after stim
            stim_sample_count = optotap_observation_counts(behavior_from,behavior_to)/29; % 29 is 2 seconds
            control_sample_count = control_optotap_observation_counts(behavior_from,behavior_to)/29;
            stim_samples = false(1,stim_sample_count);
            stim_samples(1:optotap_transitions_counts(behavior_from,behavior_to)) = true;            
            control_samples = false(1,control_sample_count);
            control_samples(1:control_optotap_transitions_counts(behavior_from,behavior_to)) = true;
            bootstrap_frac_inc = zeros(1,bootstrap_n);
            for bootstrap_index = 1:bootstrap_n
                bootstrap_stim_sample = datasample(stim_samples,stim_sample_count);
                bootstrap_control_sample = datasample(control_samples,stim_sample_count);
                if any(bootstrap_control_sample)
                    bootstrap_frac_inc(bootstrap_index) = (sum(bootstrap_stim_sample)/stim_sample_count) / (sum(bootstrap_control_sample)/control_sample_count);
                end
            end
            bootstrap_fractional_increases{behavior_from,behavior_to} = bootstrap_frac_inc;
            
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

%plot reversal fractioal increase from bootstrapping
behavior_to = 3;
turn_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{2,behavior_to});
turn_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{2,behavior_to});

fwd_bootstrap_frac_inc_mean = mean(bootstrap_fractional_increases{1,behavior_to});
fwd_bootstrap_frac_inc_std = std(bootstrap_fractional_increases{1,behavior_to});

%get p value using 2 tails
bootstrap_frac_inc_diff = bootstrap_fractional_increases{1,behavior_to} - bootstrap_fractional_increases{2,behavior_to};
bootstrap_frac_inc_diff_mean_offset_abs = abs(bootstrap_frac_inc_diff - mean(bootstrap_frac_inc_diff));
mean_distance = abs(turn_bootstrap_frac_inc_mean - fwd_bootstrap_frac_inc_mean);
p = sum(bootstrap_frac_inc_diff_mean_offset_abs > mean_distance) ./ length(bootstrap_frac_inc_diff_mean_offset_abs); %find the fraction of points with larger difference when the null is true

figure('pos',[10 10 200 300])
barwitherr([fwd_bootstrap_frac_inc_std; turn_bootstrap_frac_inc_std], [fwd_bootstrap_frac_inc_mean; turn_bootstrap_frac_inc_mean],'FaceColor',behavior_colors(behavior_to,:))
ax = gca;
if p < 0.05
    sigstar({[1,2]},p);
end
box('off')
set(gca,'YTick',[0 10])
set(gca,'XTickLabel',{'Fwd','Turn'})
set(gca,'fontsize',14)
ylabel('Times More Likely to Reverse with Stim')
title(['p=', num2str(p)])
axis([0 3 0 10]);

%plot it
figure
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            if control_optotap_transitions_counts(behavior_from,behavior_to) == 0 && optotap_transitions_counts(behavior_from,behavior_to) == 0
            else
                scrollsubplot(rows_per_page,double(number_of_behaviors),double((behavior_from-1)*number_of_behaviors+behavior_to))
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
                new_ylim = y_limits(2);
%                new_ylim = 2;
                if new_ylim > 1
                    new_ylim = ceil(y_limits(2));
                else
                    new_ylim = 1;
                end
                axis([0 3 0 new_ylim]);
                if (behavior_from == 9 && behavior_to == 1) || new_ylim > 1
                    ax.YTick = linspace(0,new_ylim,2);
                else
                    set(gca,'YTick','')
                end
            end
        end
    end
end
%%  plot the 72 BTA significance a heatmap
all_edge_pairs = get_edge_pairs(number_of_behaviors);
BTA_percentiles = zeros(number_of_behaviors);
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        if behavior_from ~= behavior_to
            %find the behavior index
            [~, LNP_index] = ismember([behavior_from, behavior_to],all_edge_pairs,'rows');
            BTA_percentiles(behavior_from, behavior_to) = LNPStats_directional_ret(LNP_index).BTA_percentile;
        end
    end
end

figure
imagesc(BTA_percentiles)
colormap(gray)
caxis([0, 0.99])
colorbar
box('off')
set(gca,'XTick','')
set(gca,'YTick','')

%make the colormap of parula to begin with black
figure
my_colormap = parula;
my_colormap(1,:) = [0,0,0];
imagesc(BTA_percentiles) 
colormap(my_colormap)
caxis([0.989, 1])
colorbar
box('off')
set(gca,'XTick','')
set(gca,'YTick','')


%%  plot the 72 p-values in a heatmap for platetap
figure
imagesc(tap_pvalue)
colormap(flipud(gray))
caxis([0.05/72, 1])
colorbar
box('off')
set(gca,'XTick','')
set(gca,'YTick','')

%make the colormap of parula to begin with black
figure
my_colormap = flipud(parula);
my_colormap(end,:) = [0,0,0];
imagesc(tap_pvalue) 
colormap(my_colormap)
caxis([0, 0.05/72])
colorbar
box('off')
set(gca,'XTick','')
set(gca,'YTick','')

%%  plot the 72 p-values in a heatmap for optotap
figure
imagesc(optotap_pvalue)
colormap(flipud(gray))
caxis([0.05/72, 1])
colorbar
box('off')
set(gca,'XTick','')
set(gca,'YTick','')

%make the colormap of parula to begin with black
figure
my_colormap = flipud(parula);                                
my_colormap(end,:) = [0,0,0];
imagesc(optotap_pvalue) 
colormap(my_colormap)
caxis([0, 0.05/72])
colorbar
box('off')
set(gca,'XTick','')
set(gca,'YTick','')