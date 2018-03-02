%not used in paper

% load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\17_02_24_LNPStats_directional_and_nondirectional.mat')
% folders_platetap = getfoldersGUI();

%loop through all the directional LNP fitted params and determine 
LNP_significance = false(1,length(LNPStats_directional_ret));
tap_difference_significance = false(1,length(LNPStats_directional_ret));
tap_difference_p_values = zeros(1,length(LNPStats_directional_ret));
for transition_index = 1:length(LNPStats_directional_ret)
    behavior_from = LNPStats_directional_ret(transition_index).Edges(1);
    behavior_to = LNPStats_directional_ret(transition_index).Edges(2);
    [tap_transition_rates, shuffled_tap_transition_rates,h,p,~,~] = average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to);
    transition_index
    LNP_significance(transition_index) = any(LNPStats_directional_ret(transition_index).linear_kernel ~= 0);
    tap_difference_significance(transition_index) = h;
    tap_difference_p_values(transition_index) = p;
end


%select the LNP with enough data
selected_indecies = (tap_difference_p_values > 0);
selected_LNP_significance = LNP_significance(selected_indecies);
selected_tap_difference_significance = tap_difference_significance(selected_indecies);
sum(selected_LNP_significance == selected_tap_difference_significance) ./ sum(selected_indecies)
[selected_LNP_significance;selected_tap_difference_significance]
[LNP_significance;tap_difference_significance]


plotconfusion(selected_LNP_significance,selected_tap_difference_significance)
xlabel('significant for linear kernel')
ylabel('significant for tap vs control')

plotconfusion(LNP_significance,tap_difference_significance)
xlabel('significant for linear kernel')
ylabel('significant for tap vs control')

behavior_from = 6;
behavior_to = 9;
[tap_transition_rates, shuffled_tap_transition_rates,h,p,~,~] = average_transition_rate_after_tap(folders_platetap, behavior_from, behavior_to);
