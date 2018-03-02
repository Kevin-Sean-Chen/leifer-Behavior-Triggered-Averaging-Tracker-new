%not used in paper
%get the position vs time in behavioral space for given track
track_index = 5;
fps = 14;
figure
hold all
plot(0:1/fps:(length(allTracks(track_index).Frames)-1)/fps,Embeddings{track_index}(:,1))
plot(0:1/fps:(length(allTracks(track_index).Frames)-1)/fps,Embeddings{track_index}(:,2))
% plot(0:1/fps:20,Embeddings{track_index}(1:20*fps+1,1))
% plot(0:1/fps:20,Embeddings{track_index}(1:20*fps+1,2))
hold off

xlabel('Time (s)') % x-axis label
ylabel('Behavioral Space (a.u.)') % y-axis label
legend('z1', 'z2')

%get histogram of velocities in behavioral space for all data
Velocities = cell(size(Embeddings));
for track_index = 1:length(Embeddings)
    Velocities{track_index} = sqrt(diff(Embeddings{track_index}(:,1)).^2 + diff(Embeddings{track_index}(:,2)).^2);
end
allVelocities = vertcat(Velocities{:});
allVelocities = allVelocities * fps;
%allVelocities(allVelocities == 0) = eps;
allVelocities(allVelocities == 0) = []; %remove the 0 peak

edges = 10.^(-2:0.01:3); 
h = histc(allVelocities, edges);

centers = sqrt(edges(1:end-1).*edges(2:end));
figure
bar(h)
ax = gca;
xlim(ax, [0 length(centers)-1])
ax.XTickLabel = round(centers(round(ax.XTick)+1),1, 'significant');
xlabel('Speed (1/s)') % x-axis label
ylabel('Count') % y-axis label

logAllVelocities = log10(allVelocities);
edges = -2:0.01:3; 
h = histc(logAllVelocities, edges);
figure
bar(h)
ax = gca;
xlim(ax, [0 length(edges)])
ax.XTickLabel = round(10 .^ edges(round(ax.XTick)+1),1, 'significant');
xlabel('Speed (1/s)') % x-axis label
ylabel('Count') % y-axis label

GMM = fitgmdist(logAllVelocities,2); %fit a 2 gaussian gmm
GMMpdffun = @(x) pdf(GMM,x); %get its pdf
velocity_cutoff = 10 .^ fminbnd(GMMpdffun,GMM.mu(1),GMM.mu(2)); %get the local minima between the 2 gaussians

figure
hold on
ezplot(GMMpdffun)
x=[log10(velocity_cutoff),log10(velocity_cutoff)];
y=[0,1];
plot(x,y)

hold off

ax = gca;
ax.XTickLabel = round(10.^ax.XTick,1, 'significant');
xlabel('Speed (1/s)') % x-axis label
ylabel('pdf') % y-axis label
