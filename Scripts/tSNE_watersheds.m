%taken from returnTemplates.m
maxVal = max(max(abs(embeddingValues)));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40; %change smoothing factor if necessary
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density] = findPointDensity(embeddingValues,sigma,501,[-maxVal maxVal]);
density(density < 10e-6) = 0;
L = watershed(-density,8);
[ii,jj] = find(L==0);

hold on
imagesc(xx,xx,density)
axis equal tight off xy
caxis([0 maxDensity * .8])
colormap(jet)
plot(xx(jj),xx(ii),'k.') %watershed borders
hold off
