function active_track_indecies = PlotFrame(FigH, Frame, Tracks, frame_index, LEDPower, all_deleted_tracks)

figure(FigH)
clf;
%imshow(Frame,'InitialMagnification',300);
imshow(Frame,'InitialMagnification',100, 'Border','tight');
hold on;
fps = 14;
active_track_indecies = [];
if nargin < 4
    %plot during tracking
    if ~isempty(Tracks)
        ActiveTracks = find([Tracks.Active]);
    else
        ActiveTracks = [];
    end

    for i = 1:length(ActiveTracks)
        figure(FigH)
        plot(Tracks(ActiveTracks(i)).Path(:,1), Tracks(ActiveTracks(i)).Path(:,2), 'r');
        %plot(Tracks(ActiveTracks(i)).LastCoordinates(1), Tracks(ActiveTracks(i)).LastCoordinates(2), 'wo');
        %(Tracks(ActiveTracks(i)).LastCoordinates(1)+10, Tracks(ActiveTracks(i)).LastCoordinates(2)+10, num2str(ActiveTracks(i)), 'color', 'g')
    end
else
    %plot after analysis
    if ~isempty(Tracks)
        track_indecies_in_frame = find([Tracks.Frames] == frame_index);
        frameSum = 0;
        currentActiveTrack = 1; %keeps the index of the track_indecies_in_frame
        myColors = winter(length(track_indecies_in_frame));
        for track_index = 1:length(Tracks)
            if currentActiveTrack > length(track_indecies_in_frame)
                %all active tracks found
                break;
            end
            if track_indecies_in_frame(currentActiveTrack) - frameSum <= length(Tracks(track_index).Frames) 
                %active track found
                in_track_index = track_indecies_in_frame(currentActiveTrack) - frameSum;
                plot(Tracks(track_index).Path(1:in_track_index,1), Tracks(track_index).Path(1:in_track_index,2), 'Color', myColors(currentActiveTrack,:));
                plot(Tracks(track_index).Path(in_track_index,1), Tracks(track_index).Path(in_track_index,2),'x' , 'Color', myColors(currentActiveTrack,:));
%                 text(Tracks(track_index).Path(in_track_index,1)+10, Tracks(track_index).Path(in_track_index,2)+10, num2str(track_index), 'Color', myColors(currentActiveTrack,:));
                currentActiveTrack = currentActiveTrack + 1;
                active_track_indecies = [active_track_indecies, track_index];
            end
            frameSum = frameSum + length(Tracks(track_index).Frames);
        end
    end
    
    %deleted tracks plotting
    if ~isempty(all_deleted_tracks)
        track_indecies_in_frame = find([all_deleted_tracks.Frames] == frame_index);
        frameSum = 0;
        currentActiveTrack = 1; %keeps the index of the track_indecies_in_frame
        myColors = autumn(length(track_indecies_in_frame));
        for track_index = 1:length(all_deleted_tracks)
            if currentActiveTrack > length(track_indecies_in_frame)
                %all active tracks found
                break;
            end
            if track_indecies_in_frame(currentActiveTrack) - frameSum <= length(all_deleted_tracks(track_index).Frames) 
                %active track found
                in_track_index = track_indecies_in_frame(currentActiveTrack) - frameSum;
                plot(all_deleted_tracks(track_index).Path(1:in_track_index,1), all_deleted_tracks(track_index).Path(1:in_track_index,2), 'Color', myColors(currentActiveTrack,:));
                plot(all_deleted_tracks(track_index).Path(in_track_index,1), all_deleted_tracks(track_index).Path(in_track_index,2),'o' , 'Color', myColors(currentActiveTrack,:));
                if ~isempty(all_deleted_tracks(track_index).DeletionReason)
                    text(all_deleted_tracks(track_index).Path(in_track_index,1)+10, all_deleted_tracks(track_index).Path(in_track_index,2)+10, all_deleted_tracks(track_index).DeletionReason, 'Color', myColors(currentActiveTrack,:));
                end
                currentActiveTrack = currentActiveTrack + 1;
                active_track_indecies = [active_track_indecies, track_index];
            end
            frameSum = frameSum + length(all_deleted_tracks(track_index).Frames);
        end
    end
    
    if nargin > 4
        %LEDVoltage specified, plot it
        [frame_h, frame_w] = size(Frame);
        plot_x = ceil(frame_w - (frame_w/10));
        plot_y = ceil(frame_h/10);
        time_text = ['t=', datestr(abs(frame_index)/24/3600/fps,'MM:SS.FFF')];

        plot(plot_x, plot_y, 'o', 'MarkerSize', 50, 'MarkerEdgeColor','none', 'MarkerFaceColor',[min(max(LEDPower/80,0),1) 0 0])
        text(plot_x+150,plot_y+130, [num2str(round(LEDPower)), ' uW mm^{-2}'], 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'color', [1 0 0], 'fontsize', 20);
        text(plot_x+150,plot_y+220, time_text, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle', 'color', [1 1 1], 'fontsize', 20);
        
    end
    
end

axis tight
hold off;    % So not to see movie replay