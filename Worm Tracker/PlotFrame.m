function PlotFrame(FigH, Frame, Tracks, frame_index, LEDVoltage)

figure(FigH)
imshow(Frame);
hold on;

%global Prefs;

% figure(FigH+1)
% imshow(RGB);
% hold on;
if nargin < 4
    %plot during tracking
    if ~isempty(Tracks)
        ActiveTracks = find([Tracks.Active]);
    else
        ActiveTracks = [];
    end

    for i = 1:length(ActiveTracks)
        figure(FigH)
    %   cmap = colormap;    'Color', cmap(ActiveTracks(i)*10,:)
        plot(Tracks(ActiveTracks(i)).Path(:,1), Tracks(ActiveTracks(i)).Path(:,2), 'r');
        %plot(Tracks(ActiveTracks(i)).LastCoordinates(1), Tracks(ActiveTracks(i)).LastCoordinates(2), 'b+');

    %   figure(FigH+1)
       plot(Tracks(ActiveTracks(i)).LastCoordinates(1), Tracks(ActiveTracks(i)).LastCoordinates(2), 'wo');
       text(Tracks(ActiveTracks(i)).LastCoordinates(1)+10, Tracks(ActiveTracks(i)).LastCoordinates(2)+10, num2str(ActiveTracks(i)), 'color', 'g')
    end
else
    %plot reversals after analysis
    if ~isempty(Tracks)
        track_indecies_in_frame = find([Tracks.Frames] == frame_index);
        frameSum = 0;
        currentActiveTrack = 1; %keeps the index of the track_indecies_in_frame
        myColors = winter(length(track_indecies_in_frame));
        for i = 1:length(Tracks)
            if currentActiveTrack > length(track_indecies_in_frame)
                %all active tracks found
                break;
            end
            if track_indecies_in_frame(currentActiveTrack) - frameSum <= Tracks(i).NumFrames 
                %active track found
                in_track_index = track_indecies_in_frame(currentActiveTrack) - frameSum;
                
                plot(Tracks(i).Path(1:in_track_index,1), Tracks(i).Path(1:in_track_index,2), 'Color', myColors(currentActiveTrack,:));

%                 %find out if worm is in the middle of a reversal
%                 pirouettes = Tracks(i).Pirouettes;
%                 %pirouettes = Tracks(i).Runs;
%                 pirouetting = 0;
%                 for pirouette_index = 1:size(pirouettes,1)
%                     pirouetteStart = pirouettes(pirouette_index,1);
%                     pirouetteEnd = pirouettes(pirouette_index,2);
%                     if in_track_index >= pirouetteStart && in_track_index <= pirouetteEnd
%                         pirouetting = 1;
%                     end
%                     if in_track_index >= pirouetteEnd
%                         plot(Tracks(i).Path(pirouetteStart:pirouetteEnd,1), Tracks(i).Path(pirouetteStart:pirouetteEnd,2), 'x', 'Color', myColors(currentActiveTrack,:));
%                     elseif in_track_index >= pirouetteStart && in_track_index < pirouetteEnd
%                         plot(Tracks(i).Path(pirouetteStart:in_track_index,1), Tracks(i).Path(pirouetteStart:in_track_index,2), 'rx');
%                     end
%                 end
%                 

%                 if pirouetting
%                     %worm is reversing
%                     plot(Tracks(i).Path(in_track_index,1), Tracks(i).Path(in_track_index,2), 'ro', 'LineWidth', 1);
%                      %plot the track number and size
%                      text(Tracks(i).Path(in_track_index,1)+10, Tracks(i).Path(in_track_index,2)+10, num2str(i), 'Color', 'r')
% %                     text(Tracks(i).Path(in_track_index,1)+10, Tracks(i).Path(in_track_index,2)+10, [num2str(i), char(10), num2str(Tracks(i).Size(in_track_index)), char(10), num2str(Tracks(i).SmoothSpeed(in_track_index))], 'Color', 'r')
%                 else
                    plot(Tracks(i).Path(in_track_index,1), Tracks(i).Path(in_track_index,2), 'Marker', 'o', 'Color', myColors(currentActiveTrack,:));
                     %plot the track number and size
                     text(Tracks(i).Path(in_track_index,1)+10, Tracks(i).Path(in_track_index,2)+10, num2str(i), 'Color', myColors(currentActiveTrack,:))
%                     text(Tracks(i).Path(in_track_index,1)+10, Tracks(i).Path(in_track_index,2)+10, [num2str(i), char(10), num2str(Tracks(i).Size(in_track_index)), char(10), num2str(Tracks(i).SmoothSpeed(in_track_index))], 'Color', myColors(currentActiveTrack,:))
%                end
                
                
%                 if abs(Tracks(i).AngSpeed(in_track_index)) < Prefs.PirThresh
%                     text(Tracks(i).Path(in_track_index,1)+10, Tracks(i).Path(in_track_index,2)+90, num2str(Tracks(i).AngSpeed(in_track_index)), 'Color', myColors(currentActiveTrack,:))
%                 else
%                     text(Tracks(i).Path(in_track_index,1)+10, Tracks(i).Path(in_track_index,2)+90, num2str(Tracks(i).AngSpeed(in_track_index)), 'Color', 'r', 'FontWeight', 'bold')
%                 end

                currentActiveTrack = currentActiveTrack + 1;
            end
            frameSum = frameSum + Tracks(i).NumFrames;
        end
    end
    if nargin > 4
        %LEDVoltage specified, plot it
        [frame_h, frame_w] = size(Frame);
        plot_x = ceil(frame_w - (frame_w/10));
        plot_y = ceil(frame_h/10);
        plot(plot_x, plot_y, 'o', 'MarkerSize', 30, 'MarkerEdgeColor','none', 'MarkerFaceColor',[LEDVoltage/5 0 0])
    end
    
end



%pause(1);
hold off;    % So not to see movie replay