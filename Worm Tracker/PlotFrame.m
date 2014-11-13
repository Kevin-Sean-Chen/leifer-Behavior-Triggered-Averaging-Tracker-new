function PlotFrame(FigH, Mov, Tracks, RGB)

figure(FigH)
imshow(Mov.cdata, Mov.colormap);
hold on;

% figure(FigH+1)
% imshow(RGB);
% hold on;

if ~isempty(Tracks)
    ActiveTracks = find([Tracks.Active]);
else
    ActiveTracks = [];
end

for i = 1:length(ActiveTracks)
    figure(FigH)
%   cmap = colormap;    'Color', cmap(ActiveTracks(i)*10,:)
    plot(Tracks(ActiveTracks(i)).Path(:,1), Tracks(ActiveTracks(i)).Path(:,2), 'r');
    plot(Tracks(ActiveTracks(i)).LastCoordinates(1), Tracks(ActiveTracks(i)).LastCoordinates(2), 'b+');
    
%   figure(FigH+1)
%   plot(Tracks(ActiveTracks(i)).LastCoordinates(1), Tracks(ActiveTracks(i)).LastCoordinates(2), 'wo');
end

pause(1);
hold off;    % So not to see movie replay