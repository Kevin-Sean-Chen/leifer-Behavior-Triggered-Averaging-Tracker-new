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

%%

%folders_platetap = getfoldersGUI();

%intialize
tap_transition_rates = zeros(number_of_behaviors,number_of_behaviors,length(folders_platetap));
control_tap_transition_rates = zeros(number_of_behaviors,number_of_behaviors,length(folders_platetap));
statistical_significant = zeros(number_of_behaviors,number_of_behaviors);
p_values = zeros(number_of_behaviors,number_of_behaviors);

%loop through all the possible behaviors and get stats
for behavior_from = 1:number_of_behaviors
    for behavior_to = 1:number_of_behaviors
        display([num2str(behavior_from) ' to ' num2str(behavior_to)])
        [tap_transition_rates(behavior_from,behavior_to,:),control_tap_transition_rates(behavior_from,behavior_to,:), ...
            statistical_significant(behavior_from,behavior_to),p_values(behavior_from,behavior_to),~,~] = average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to);
    end
end

%find the mean and std
mean_tap_transition_rates = mean(tap_transition_rates,3);
std_tap_transition_rates = std(tap_transition_rates,0,3);
mean_control_transition_rates = mean(control_tap_transition_rates,3);
std_control_transition_rates = std(control_tap_transition_rates,0,3);

%find the percent change between control and tap conditions and the
%appropriate error
tap_control_ratio = mean_tap_transition_rates ./ mean_control_transition_rates;
propagated_errors = tap_control_ratio .* sqrt(((std_tap_transition_rates./mean_tap_transition_rates).^2)+((std_control_transition_rates./mean_control_transition_rates).^2));

%% plot the percent changes along with its error
xaxis_labels = {};
figure
hold on
axis_count = 1;
for behavior_to = 1:number_of_behaviors
    for behavior_from = 1:number_of_behaviors
        if statistical_significant(behavior_from,behavior_to)
            errorbar(axis_count,tap_control_ratio(behavior_from,behavior_to),propagated_errors(behavior_from,behavior_to),'r*');
        else
            errorbar(axis_count,tap_control_ratio(behavior_from,behavior_to),propagated_errors(behavior_from,behavior_to),'bo');
        end
        xaxis_labels{axis_count} = [num2str(behavior_from) 'To' num2str(behavior_to)];
        axis_count = axis_count + 1;
    end
end
plot(1:axis_count, ones(1,axis_count), 'r', 'Linewidth', 3)

% axis([1 axis_count 0 max(tap_control_ratio(:))])
axis([1 axis_count 0 25])
set(gca, 'XTick', 1:axis_count)
set(gca,'XTickLabel',xaxis_labels)
set(gca,'XTickLabelRotation',90)
ylabel('Transition Rate Ratio (Tap/Control)')

%% understanding the relationship between N2 platetap and mec-4 optotap

%load the LNPstats
load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\17_02_24_LNPStats_directional_and_nondirectional.mat')

%get the non-linearity range
LNPStats_directional_ret(1).NLratio = [];
LNPStats_directional_ret(1).NLratioError = [];
LNPStats_directional_ret(1).N2TapControlRatio = [];
LNPStats_directional_ret(1).N2TapControlError = [];
LNPStats_directional_ret(1).N2TapControlSignificance = [];

for LNP_index = 1:length(LNPStats_directional_ret)
    if isempty(LNPStats_directional_ret(LNP_index).filtered_signal_histogram)
        LNPStats_directional_ret(LNP_index).NLratio = [];
        LNPStats_directional_ret(LNP_index).NLratioError = [];
    else
        %get the largest and smallest nonlinearity elements and their
        %errors
        [NLMax, NLMax_index] = max(LNPStats_directional_ret(LNP_index).non_linearity);
        [NLMin, NLMin_index] = min(LNPStats_directional_ret(LNP_index).non_linearity);

        LNPStats_directional_ret(LNP_index).NLratio = NLMax / NLMin;
        LNPStats_directional_ret(LNP_index).NLratioError = LNPStats_directional_ret(LNP_index).NLratio .* sqrt(((LNPStats_directional_ret(LNP_index).errors(NLMax_index)./NLMax).^2)+((LNPStats_directional_ret(LNP_index).errors(NLMin_index)./NLMin).^2));
    end
    
    LNPStats_directional_ret(LNP_index).N2TapControlRatio = tap_control_ratio(LNPStats_directional_ret(LNP_index).Edges(1), LNPStats_directional_ret(LNP_index).Edges(2));
    LNPStats_directional_ret(LNP_index).N2TapControlError = propagated_errors(LNPStats_directional_ret(LNP_index).Edges(1), LNPStats_directional_ret(LNP_index).Edges(2));
    LNPStats_directional_ret(LNP_index).N2TapControlSignificance = statistical_significant(LNPStats_directional_ret(LNP_index).Edges(1), LNPStats_directional_ret(LNP_index).Edges(2));
end

%% plot the relationship

figure
hold on
for LNP_index = 1:length(LNPStats_directional_ret)
    if ~isempty(LNPStats_directional_ret(LNP_index).NLratio) && ~isnan(LNPStats_directional_ret(LNP_index).N2TapControlError)
        current_fit = LNPStats_directional_ret(LNP_index).non_linearity_fit;
        LNPStats_directional_ret(LNP_index).NLratio = current_fit(LNPStats_directional_ret(LNP_index).bin_edges(end)) / current_fit(LNPStats_directional_ret(LNP_index).bin_edges(1));
        if LNPStats_directional_ret(LNP_index).N2TapControlSignificance
            errorbarxy(LNPStats_directional_ret(LNP_index).NLratio,LNPStats_directional_ret(LNP_index).N2TapControlRatio, ...
                LNPStats_directional_ret(LNP_index).N2TapControlError, ...
                LNPStats_directional_ret(LNP_index).NLratioError,{'r*', 'r', 'r'});
        else
            errorbarxy(LNPStats_directional_ret(LNP_index).NLratio,LNPStats_directional_ret(LNP_index).N2TapControlRatio, ...
                LNPStats_directional_ret(LNP_index).N2TapControlError, ...
                LNPStats_directional_ret(LNP_index).NLratioError,{'bo', 'b', 'b'});
        end
        
        text(LNPStats_directional_ret(LNP_index).NLratio,LNPStats_directional_ret(LNP_index).N2TapControlRatio, ...
            ['  ' num2str(LNPStats_directional_ret(LNP_index).Edges(1)) '\rightarrow' num2str(LNPStats_directional_ret(LNP_index).Edges(2))], ...
            'HorizontalAlignment','left')
    end
end

% axis([1 axis_count 0 max(tap_control_ratio(:))])
axis([0 7 0 10])
% set(gca, 'XTick', 1:axis_count)
% set(gca,'XTickLabel',xaxis_labels)
% set(gca,'XTickLabelRotation',90)
ylabel('Transition Rate Ratio (Tap/Control)')
xlabel('LNP Non-linearity Ratio (Max/Min)')

%% animals ignore mechanosensory stimulus while turning? make the figure to find out
behavior_from = 3;

all_edge_pairs = get_edge_pairs(number_of_behaviors);

mean_tap_transition_rates = zeros(1, number_of_behaviors);
std_tap_transition_rates =  zeros(1, number_of_behaviors);
tap_observed_transitions_counts = zeros(1, number_of_behaviors);
mean_shuffled_tap_transition_rates = zeros(1, number_of_behaviors);
std_shuffled_tap_transition_rates =  zeros(1, number_of_behaviors);
shuffled_tap_observed_transitions_counts = zeros(1, number_of_behaviors);
tap_difference_significant = false(1, number_of_behaviors);


for behavior_to = 1:number_of_behaviors
    if behavior_from ~= behavior_to
        [tap_transition_rates,control_tap_transition_rates,h,~,~,~,tap_observed_transitions_count,control_observed_transitions_count] = average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to);
        mean_tap_transition_rates(behavior_to) = mean(tap_transition_rates);
        std_tap_transition_rates(behavior_to) = std(tap_transition_rates);
        mean_shuffled_tap_transition_rates(behavior_to) = mean(control_tap_transition_rates);
        std_shuffled_tap_transition_rates(behavior_to) = std(control_tap_transition_rates);
        tap_difference_significant(behavior_to) = h;
        tap_observed_transitions_counts(behavior_to) = tap_observed_transitions_count;
        shuffled_tap_observed_transitions_counts(behavior_to) = control_observed_transitions_count;
    end
end

mean_optotap_transition_rates = zeros(1, number_of_behaviors);
std_optotap_transition_rates =  zeros(1, number_of_behaviors);
optotap_observed_transitions_counts = zeros(1, number_of_behaviors);
mean_shuffled_optotap_transition_rates = zeros(1, number_of_behaviors);
std_shuffled_optotap_transition_rates =  zeros(1, number_of_behaviors);
shuffled_optotap_observed_transitions_counts = zeros(1, number_of_behaviors);
optotap_difference_significant = false(1, number_of_behaviors);
for behavior_to = 1:number_of_behaviors
    if behavior_from ~= behavior_to
        [tap_transition_rates,control_tap_transition_rates,h,~,~,~,tap_observed_transitions_count,control_observed_transitions_count] = average_transition_rate_after_tap(folders_optotap, behavior_from, behavior_to);
        mean_optotap_transition_rates(behavior_to) = mean(tap_transition_rates);
        std_optotap_transition_rates(behavior_to) = std(tap_transition_rates);
        mean_shuffled_optotap_transition_rates(behavior_to) = mean(control_tap_transition_rates);
        std_shuffled_optotap_transition_rates(behavior_to) = std(control_tap_transition_rates);
        optotap_difference_significant(behavior_to) = h;
        optotap_observed_transitions_counts(behavior_to) = tap_observed_transitions_count;
        shuffled_optotap_observed_transitions_counts(behavior_to) = control_observed_transitions_count;
    end
end

figure 
% first row is kernels
for behavior_to = 1:number_of_behaviors
    if behavior_from ~= behavior_to
        subplot(double(3),double(number_of_behaviors),double(behavior_to))
        [~, LNP_index] = ismember([behavior_from, behavior_to],all_edge_pairs,'rows');
        behavior_color = behavior_colors(behavior_to,:);
        
        hold on
        if LNPStats(LNP_index).BTA_percentile > 0.99
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, '-', 'color',behavior_color, 'Linewidth', 3);
        else
            plot(-BTA_seconds_before:1/fps:BTA_seconds_after, LNPStats(LNP_index).BTA, '-', 'color',[0.9, 0.9, 0.9], 'Linewidth', 3);
        end
        hold off
        xlabel(['n=',num2str(LNPStats(LNP_index).trigger_count)]) % x-axis label
        axis([-10 10 23 27])
        %axis([-10 2 0 5])
        ax = gca;
        ax.FontSize = 10;
        xlabh = get(gca,'XLabel');
        %set(xlabh,'Position',get(xlabh,'Position') + [0 1.6 0])
        set(gca,'XTick','')
        set(gca,'YTick','')
    end
end

% second row is optotap responses
for behavior_to = 1:number_of_behaviors
    if behavior_from ~= behavior_to
        subplot(double(3),double(number_of_behaviors),double(number_of_behaviors+behavior_to))
        
        barwitherr([std_shuffled_optotap_transition_rates(behavior_to); std_optotap_transition_rates(behavior_to)], [mean_shuffled_optotap_transition_rates(behavior_to); mean_optotap_transition_rates(behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
        axis([0 3 0 40])
        if optotap_difference_significant(behavior_to)
            sigstar({[1,2]},0.05,0,30);
        else
            sigstar({[1,2]},nan,0,30);           
        end
%         set(gca,'XTickLabel',{['n=',num2str(shuffled_optotap_observed_transitions_counts(behavior_to))],['n=',num2str(optotap_observed_transitions_counts(behavior_to))]})
        set(gca,'XTickLabel',{['n=',num2str(shuffled_optotap_observed_transitions_counts(behavior_to)),', ',num2str(optotap_observed_transitions_counts(behavior_to))],''})
        if behavior_to == 1
            ylabel('OptoTap Transition Rate (transitions/min)')
        else
            set(gca,'YTick','')
        end
    end
end
% third row is tap responses
for behavior_to = 1:number_of_behaviors
    if behavior_from ~= behavior_to
        subplot(double(3),double(number_of_behaviors),double(2*number_of_behaviors+behavior_to))
        
        barwitherr([std_shuffled_tap_transition_rates(behavior_to); std_tap_transition_rates(behavior_to)], [mean_shuffled_tap_transition_rates(behavior_to); mean_tap_transition_rates(behavior_to)],'FaceColor',behavior_colors(behavior_to,:))
        axis([0 3 0 40])
        if tap_difference_significant(behavior_to)
            sigstar({[1,2]},0.05,0,30);
        else
            sigstar({[1,2]},nan,0,30);           
        end
        set(gca,'XTickLabel',{['n=',num2str(shuffled_tap_observed_transitions_counts(behavior_to)),', ',num2str(tap_observed_transitions_counts(behavior_to))],''})
        if behavior_to == 1
            ylabel('Tap Transition Rate (transitions/min)')
        else
            set(gca,'YTick','')
        end
    end
end