load('reference_embedding.mat')                    

figure
scatter(trainingEmbedding(:,1),trainingEmbedding(:,2),1,trainingSetData(:,end),'filled')
axis equal tight
axis([xlimits ylimits]) %use xlimits and ylimits from normal watershet plot
colormap(redblue)
set(gca,'xtick',xlimits);
set(gca,'ytick',ylimits);
