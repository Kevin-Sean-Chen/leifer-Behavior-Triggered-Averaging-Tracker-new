function [] = CompareHistograms(Distributions)
%COMPAREHISTOGRAMS takes in several distributions and plots themm
%   Detailed explanation goes here
    
    colors = jet(length(Distributions));
    edges = linspace(min([Distributions.Values]), max([Distributions.Values]),30);
    
    figure
    hold all;
    for distribution_index = 1:length(Distributions)
        [n,x] = hist(Distributions(distribution_index).Values,edges);
        h = bar(x, n, 'hist');
        %findobj(gca,'Type','patch');
        set(h,'FaceColor',colors(distribution_index,:),'EdgeColor','w','facealpha',0.2)
    end

    xlabel('Scores')
    ylabel('Count')
%     legend(Distribution1Name, Distribution2Name);
%     legend('show')
%     title(['Wilcoxon Rank Sum p = ', num2str(p)])
end