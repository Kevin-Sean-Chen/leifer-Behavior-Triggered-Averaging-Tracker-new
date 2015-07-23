function [ p ] = CompareTwoHistograms(Distribution1, Distribution2, Distribution1Name, Distribution2Name)
%COMPAREHISTOGRAMS takes in 2 distributions and plots them along with
%returning the p value for the Wilcoxon Rank Sum test
%   Detailed explanation goes here
    
    %p = ranksum(Distribution1,Distribution2, 'tail', 'right');
    p = ranksum(Distribution1,Distribution2);
    
    edges = linspace(min([Distribution1, Distribution2]), max([Distribution1, Distribution2]),30);
    
    figure
    hold all;
    hist(Distribution1,edges)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)

    hist(Distribution2,edges)
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
    xlabel('Scores')
    ylabel('Count')
    legend(Distribution1Name, Distribution2Name);
    legend('show')
    title(['Wilcoxon Rank Sum p = ', num2str(p)])
end

