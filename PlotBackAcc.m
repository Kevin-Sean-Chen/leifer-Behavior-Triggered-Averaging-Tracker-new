%plotting backwardacc


figure
track_number = 26;
hold on
plot(Tracks(track_number).AngSpeed(1:200)/max(Tracks(track_number).AngSpeed(1:200)))
plot(Tracks(track_number).BackwardAcc(1:200)/max(Tracks(track_number).BackwardAcc(1:200)))
plot(Tracks(track_number).Speed(1:200))
smooth = smoothts(Tracks(track_number).Speed(1:200), 'g', 7, 7);
plot(smooth)

hold off