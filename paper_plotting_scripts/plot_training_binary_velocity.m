                    


scatter(trainingEmbedding(:,1),trainingEmbedding(:,2),1,trainingSetData(:,end),'filled')
axis equal tight xy
colormap(redblue)
colorbar
axis([xlimits,ylimits])
set(gca,'xtick',xlimits);
set(gca,'ytick',ylimits);
