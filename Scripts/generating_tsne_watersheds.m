%taken from returnTemplates.m
minTemplateLength = 10;
kdNeighbors = 2000;
plotsOn = true;

yData = combineCells(Embeddings);

maxY = ceil(max(abs(yData(:)))) + 1;

% NS = createns(yData);
% [~,D] = knnsearch(NS,yData,'K',kdNeighbors+1);

sigma = 4.12;%median(D(:,kdNeighbors+1));

[xx,density] = findPointDensity(yData,sigma,501,[-maxY maxY]);

density(density < 10e-6) = 0;

L = watershed(-density,8);
% vals = round((yData + max(xx))*length(xx)/(2*max(xx)));

% N = length(D(:,1));
% watershedValues = zeros(N,1);
% for i=1:N
%     watershedValues(i) = diag(L(vals(i,2),vals(i,1)));
% end
% 
% idx = find(lengths >= minTemplateLength);
% vals2 = zeros(size(watershedValues));
% for i=1:length(idx)
%     vals2(watershedValues == idx(i)) = i;
% end
% 
% lengths = lengths(lengths >= minTemplateLength);



if plotsOn
    hold on
    imagesc(xx,xx,density);
    %set(gca,'ydir','normal');

    axis equal tight off xy
    caxis([0 maxDensity * .8])
    colormap(jet)
    [ii,jj] = find(L==0);
    plot(xx(jj),xx(ii),'k.')

    hold off
end