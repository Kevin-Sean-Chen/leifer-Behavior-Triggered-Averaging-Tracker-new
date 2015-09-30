%make a histogram
N = transpose(hist3([transpose([Tracks.SmoothSpeed]), transpose(abs([Tracks.AngSpeed]))], {0:.025:1,0:80:3200})); %count up the frequencies for this bivariate histogram
%N = N / sum(sum(N)); %normalize so that N is a proper probability distribution
figure
imagesc(log(N)) %plot these frequencies as colors
colorbar %show the scale
axis xy
set(gca, 'XTick',1:41,'XTickLabel',0:.025:1)
set(gca, 'YTick',1:41,'YTickLabel',0:80:3200)
xlabel('Speed (mm/s)')
ylabel('Ang Speed (degrees/s)')
title('log distribution of Speed and Angular Speed')