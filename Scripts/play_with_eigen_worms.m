center_lines = cat(3,Tracks(47).Centerlines);
thetas = centerlines_to_angles(center_lines);

[eigen_values, eigen_vectors] = myPCA(thetas);
eigen_values = sum(eigen_values,2);
totalvar = sum(sum(eigen_values,2));

PCsToPlot = 8;
figure
hold on
plot(cumsum(eigen_values(1:PCsToPlot))/totalvar*100, 'ro')
plot(0:PCsToPlot, repmat(100, 1, PCsToPlot+1), '-.k');
hold off
xlabel(['Principle Components 1 to ', num2str(PCsToPlot)])
ylabel('Percent of Total Variance Captured')
axis([0 PCsToPlot 0 110]);
% total_percent_variance = 0;
% for i = 1:size(eigen_values)
%     total_percent_variance = total_percent_variance + (eigen_values(i)/totalvar*100);
%     if total_percent_variance > 90
%         %stop when total variance is above 90%
%         i
%         break
%     end
% end
% % the first 4 principle components explain 90 percent of the total variance
% (eigen_values(1)/totalvar*100) + (eigen_values(2)/totalvar*100)
% %the first two principal componets explain 66.42 percent of the variance

%plot the first 4 principle components
figure
plot(1:length(eigen_vectors), eigen_vectors(:,1))
xlabel('Position Along the Worm')
ylabel('PC1 Loadings')
figure
plot(1:length(eigen_vectors), eigen_vectors(:,2))
xlabel('Position Along the Worm')
ylabel('PC2 Loadings')
figure
plot(1:length(eigen_vectors), eigen_vectors(:,3))
xlabel('Position Along the Worm')
ylabel('PC3 Loadings')
figure
plot(1:length(eigen_vectors), eigen_vectors(:,4))
xlabel('Position Along the Worm')
ylabel('PC4 Loadings')


mean_centered_thetas = thetas - (diag(mean(thetas, 2))*ones(size(thetas)));
projected_matrix = eigen_vectors\mean_centered_thetas; %inv(eigen_vectors)*mean_centered_thetas

x = transpose(projected_matrix(1,:));
y = transpose(projected_matrix(2,:));

%normalize x and y to be on the same scale (this is done in the paper)
x = x / sqrt((dot(x,x)/size(x,1)));
y = y / sqrt((dot(y,y)/size(y,1)));
%make a histogram
N = hist3([x y],{-2:.1:2,-2:.1:2}); %count up the frequencies for this bivariate histogram
N = N / sum(sum(N)); %normalize so that N is a proper probability distribution
N = N(2:end-1, 2:end-1);
figure
imagesc(N) %plot these frequencies as colors
colorbar %show the scale
axis square
axis xy
set(gca, 'XTick',1:10:40,'XTickLabel',-2:2)
set(gca,'YTick',1:10:40,'YTickLabel',-2:2)
xlabel('normalized pc1')
ylabel('normalized pc2')
title('probability distribution: where are worms in behavioral space?')