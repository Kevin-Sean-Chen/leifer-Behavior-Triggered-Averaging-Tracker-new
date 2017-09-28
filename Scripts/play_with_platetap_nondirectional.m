load('reference_embedding.mat')
number_of_behaviors = max(L(:)-1);

%folders_platetap = getfoldersGUI();

%intialize
tap_transition_rates = zeros(number_of_behaviors,length(folders_platetap));
control_tap_transition_rates = zeros(number_of_behaviors,length(folders_platetap));
statistical_significant = zeros(1,number_of_behaviors);
p_values = zeros(1,number_of_behaviors);

%loop through all the possible behaviors and get stats
for behavior_to = 1:number_of_behaviors
    [tap_transition_rates(behavior_to,:),control_tap_transition_rates(behavior_to,:), ...
        statistical_significant(behavior_to),p_values(behavior_to),~,~] = average_transition_rate_after_tap(folders_platetap, 0, behavior_to);
end


%find the mean and std
mean_tap_transition_rates = mean(tap_transition_rates,2);
std_tap_transition_rates = std(tap_transition_rates,0,2);
mean_control_transition_rates = mean(control_tap_transition_rates,2);
std_control_transition_rates = std(control_tap_transition_rates,0,2);

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
    if statistical_significant(behavior_to)
        errorbar(axis_count,tap_control_ratio(behavior_to),propagated_errors(behavior_to),'r*');
    else
        errorbar(axis_count,tap_control_ratio(behavior_to),propagated_errors(behavior_to),'bo');
    end
    xaxis_labels{axis_count} = [num2str(behavior_to)];
    axis_count = axis_count + 1;
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
LNPStats_nondirectional_ret(1).NLratio = [];
LNPStats_nondirectional_ret(1).NLratioError = [];
LNPStats_nondirectional_ret(1).N2TapControlRatio = [];
LNPStats_nondirectional_ret(1).N2TapControlError = [];
LNPStats_nondirectional_ret(1).N2TapControlSignificance = [];

for LNP_index = 1:length(LNPStats_nondirectional_ret)
    if isempty(LNPStats_nondirectional_ret(LNP_index).filtered_signal_histogram)
        LNPStats_nondirectional_ret(LNP_index).NLratio = 1;
        LNPStats_nondirectional_ret(LNP_index).NLratioError = 0;
    else
        %get the largest and smallest nonlinearity elements and their
        %errors
        [NLMax, NLMax_index] = max(LNPStats_nondirectional_ret(LNP_index).non_linearity);
        [NLMin, NLMin_index] = min(LNPStats_nondirectional_ret(LNP_index).non_linearity);

        LNPStats_nondirectional_ret(LNP_index).NLratio = NLMax / NLMin;
        LNPStats_nondirectional_ret(LNP_index).NLratioError = LNPStats_nondirectional_ret(LNP_index).NLratio .* sqrt(((LNPStats_nondirectional_ret(LNP_index).errors(NLMax_index)./NLMax).^2)+((LNPStats_nondirectional_ret(LNP_index).errors(NLMin_index)./NLMin).^2));
    end
    
    LNPStats_nondirectional_ret(LNP_index).N2TapControlRatio = tap_control_ratio(LNP_index);
    LNPStats_nondirectional_ret(LNP_index).N2TapControlError = propagated_errors(LNP_index);
    LNPStats_nondirectional_ret(LNP_index).N2TapControlSignificance = statistical_significant(LNP_index);
end

%% plot the relationship

figure
hold on
for LNP_index = 1:length(LNPStats_nondirectional_ret)
    if ~isempty(LNPStats_nondirectional_ret(LNP_index).NLratio) && ~isnan(LNPStats_nondirectional_ret(LNP_index).N2TapControlError)
        current_fit = LNPStats_nondirectional_ret(LNP_index).non_linearity_fit;
        if LNPStats_nondirectional_ret(LNP_index).NLratioError ~= 0
            LNPStats_nondirectional_ret(LNP_index).NLratio = current_fit(LNPStats_nondirectional_ret(LNP_index).bin_edges(end)) / current_fit(LNPStats_nondirectional_ret(LNP_index).bin_edges(1));
        end
        if LNPStats_nondirectional_ret(LNP_index).N2TapControlSignificance
            errorbarxy(LNPStats_nondirectional_ret(LNP_index).NLratio,LNPStats_nondirectional_ret(LNP_index).N2TapControlRatio, ...
                LNPStats_nondirectional_ret(LNP_index).N2TapControlError, ...
                LNPStats_nondirectional_ret(LNP_index).NLratioError,{'r*', 'r', 'r'});
        else
            errorbarxy(LNPStats_nondirectional_ret(LNP_index).NLratio,LNPStats_nondirectional_ret(LNP_index).N2TapControlRatio, ...
                LNPStats_nondirectional_ret(LNP_index).N2TapControlError, ...
                LNPStats_nondirectional_ret(LNP_index).NLratioError,{'bo', 'b', 'b'});
        end
        
        text(LNPStats_nondirectional_ret(LNP_index).NLratio,LNPStats_nondirectional_ret(LNP_index).N2TapControlRatio, ...
            [num2str(LNP_index)], ...
            'HorizontalAlignment','left')
    end
end

% axis([1 axis_count 0 max(tap_control_ratio(:))])
% axis([0 7 0 10])
% set(gca, 'XTick', 1:axis_count)
% set(gca,'XTickLabel',xaxis_labels)
% set(gca,'XTickLabelRotation',90)
ylabel('Transition Rate Ratio (Tap/Control)')
xlabel('LNP Non-linearity Ratio (Max/Min)')

