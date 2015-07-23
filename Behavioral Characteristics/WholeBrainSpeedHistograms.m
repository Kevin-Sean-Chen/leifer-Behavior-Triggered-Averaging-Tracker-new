edges = linspace(0,0.3,30);
figure
hold all;

WormOrder = [3, 2, 4, 1];

markers = {'g+','ko','c*','m^'};

for track_index = 1:length(Tracks)
    % cut the tracks so that it is divisible by the bin_size
    currentTrackSpeed = Tracks(WormOrder(track_index)).SmoothSpeed;
    counts = hist(currentTrackSpeed,edges);
    probability = counts ./ sum(counts);
    plot(edges, probability, [markers{WormOrder(track_index)}, '-'])
end

xlabel('Speed (mm/s)')
ylabel('Probability')
set(gcf, 'Position', [100, 100, 300, 500]);
legend({'Worm 1', 'Worm 2', 'Worm 3', 'Worm 4'})

