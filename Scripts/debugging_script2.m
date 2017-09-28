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

