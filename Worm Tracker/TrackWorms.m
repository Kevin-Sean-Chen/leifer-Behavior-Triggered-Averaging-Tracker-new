function TrackWorms()

global WormTrackerPrefs

PlotFrameRate = str2num(get(findobj('Tag', 'PLOT_FRAME_RATE'), 'String'));    
% Display tracking results every 'PlotFrameRate' frames - increase
% this value (in GUI) to get faster tracking performance


% Get movies to track
% -------------------
MovieNames = {};
for i = 1:5
    Mname = eval(['get(findobj(''Tag'', ''MOVIE_NAME_' num2str(i) '''), ''String'')']);
    Mstart = eval(['get(findobj(''Tag'', ''MOVIE_START_' num2str(i) '''), ''String'')']);
    Mend = eval(['get(findobj(''Tag'', ''MOVIE_END_' num2str(i) '''), ''String'')']);
    if ~isempty(Mname)
        if strcmp(Mname(length(Mname)-3:length(Mname)), '.avi')
            Mname(length(Mname)-3:length(Mname)) = '';
        end
        if ~isempty(Mstart) && ~isempty(Mend)
            for j = str2num(Mstart):str2num(Mend)
                MovieNames{length(MovieNames)+1} = [Mname num2str(j) '.avi'];
            end
        else
            MovieNames{length(MovieNames)+1} = [Mname '.avi'];
        end
    end
end


% Setup figure for plotting tracker results
% -----------------------------------------
WTFigH = findobj('Tag', 'WTFIG');
if isempty(WTFigH)
    WTFigH = figure('Name', 'Tracking Results', ...
        'NumberTitle', 'off', ...
        'Tag', 'WTFIG');
else
    figure(WTFigH);
end


% Start Tracker
% -------------
for MN = 1:length(MovieNames)
    
    FileInfo = aviinfo(MovieNames{MN});
    Tracks = [];
    
    % Analyze Movie
    % -------------
    for Frame = 1:FileInfo.NumFrames
        
        % Get Frame
        Mov = aviread(MovieNames{MN}, Frame);
        
        % Convert frame to a binary image 
        if WormTrackerPrefs.AutoThreshold       % use auto thresholding
            Level = graythresh(Mov.cdata) + WormTrackerPrefs.CorrectFactor;
            Level = max(min(Level,1) ,0);
        else
            Level = WormTrackerPrefs.ManualSetLevel;
        end
        if WormTrackerPrefs.DarkObjects
            BW = ~im2bw(Mov.cdata, Level);  % For tracking dark objects on a bright background
        else
            BW = im2bw(Mov.cdata, Level);  % For tracking bright objects on a dark background
        end
        
        % Identify all objects
        [L,NUM] = BWLABEL(BW);
        STATS = regionprops(L, {'Area', 'Centroid', 'FilledArea', 'Eccentricity'});
        
        % Identify all worms by size, get their centroid coordinates
        WormIndices = find([STATS.Area] > WormTrackerPrefs.MinWormArea & ...
            [STATS.Area] < WormTrackerPrefs.MaxWormArea);
        NumWorms = length(WormIndices);
        WormCentroids = [STATS(WormIndices).Centroid];
        WormCoordinates = [WormCentroids(1:2:2*NumWorms)', WormCentroids(2:2:2*NumWorms)'];
        WormSizes = [STATS(WormIndices).Area];
        WormFilledAreas = [STATS(WormIndices).FilledArea];
        WormEccentricities = [STATS(WormIndices).Eccentricity];
        
        % Track worms 
        % ----------- 
        if ~isempty(Tracks)
            ActiveTracks = find([Tracks.Active]);
        else
            ActiveTracks = [];
        end
        
        % Update active tracks with new coordinates
        for i = 1:length(ActiveTracks)
            DistanceX = WormCoordinates(:,1) - Tracks(ActiveTracks(i)).LastCoordinates(1);
            DistanceY = WormCoordinates(:,2) - Tracks(ActiveTracks(i)).LastCoordinates(2);
            Distance = sqrt(DistanceX.^2 + DistanceY.^2);
            [MinVal, MinIndex] = min(Distance);
            if (MinVal <= WormTrackerPrefs.MaxDistance) & ...
                    (abs(WormSizes(MinIndex) - Tracks(ActiveTracks(i)).LastSize) < WormTrackerPrefs.SizeChangeThreshold)
                Tracks(ActiveTracks(i)).Path = [Tracks(ActiveTracks(i)).Path; WormCoordinates(MinIndex, :)];
                Tracks(ActiveTracks(i)).LastCoordinates = WormCoordinates(MinIndex, :);
                Tracks(ActiveTracks(i)).Frames = [Tracks(ActiveTracks(i)).Frames, Frame];
                Tracks(ActiveTracks(i)).Size = [Tracks(ActiveTracks(i)).Size, WormSizes(MinIndex)];
                Tracks(ActiveTracks(i)).LastSize = WormSizes(MinIndex);
                Tracks(ActiveTracks(i)).FilledArea = [Tracks(ActiveTracks(i)).FilledArea, WormFilledAreas(MinIndex)];
                Tracks(ActiveTracks(i)).Eccentricity = [Tracks(ActiveTracks(i)).Eccentricity, WormEccentricities(MinIndex)];
                WormCoordinates(MinIndex,:) = [];
                WormSizes(MinIndex) = [];
                WormFilledAreas(MinIndex) = [];
                WormEccentricities(MinIndex) = [];
            else
                Tracks(ActiveTracks(i)).Active = 0;
                if length(Tracks(ActiveTracks(i)).Frames) < WormTrackerPrefs.MinTrackLength
                    Tracks(ActiveTracks(i)) = [];
                    ActiveTracks = ActiveTracks - 1;
                end
            end
        end
        
        % Start new tracks for coordinates not assigned to existing tracks
        NumTracks = length(Tracks);
        for i = 1:length(WormCoordinates(:,1))
            Index = NumTracks + i;
            Tracks(Index).Active = 1;
            Tracks(Index).Path = WormCoordinates(i,:);
            Tracks(Index).LastCoordinates = WormCoordinates(i,:);
            Tracks(Index).Frames = Frame;
            Tracks(Index).Size = WormSizes(i);
            Tracks(Index).LastSize = WormSizes(i);
            Tracks(Index).FilledArea = WormFilledAreas(i);
            Tracks(Index).Eccentricity = WormEccentricities(i);
        end
        
        % Display every PlotFrameRate'th frame
        if ~mod(Frame, PlotFrameRate)
            PlotFrame(WTFigH, Mov, Tracks);
            FigureName = ['Tracking Results for Frame ', num2str(Frame)];
            set(WTFigH, 'Name', FigureName);

            if WormTrackerPrefs.PlotRGB
                RGB = label2rgb(L, @jet, 'k');
                figure(6)
                set(6, 'Name', FigureName);
                imshow(RGB);
                hold on
                if ~isempty(Tracks)
                    ActiveTracks = find([Tracks.Active]);
                else
                    ActiveTracks = [];
                end
                for i = 1:length(ActiveTracks)
                    plot(Tracks(ActiveTracks(i)).LastCoordinates(1), ...
                        Tracks(ActiveTracks(i)).LastCoordinates(2), 'wo');
                end
                hold off
            end
            
            if WormTrackerPrefs.PlotObjectSizeHistogram
                figure(7)
                hist([STATS.Area],300)
                set(7, 'Name', FigureName);
                title('Histogram of Object Sizes Identified by Tracker')
                xlabel('Object Size (pixels')
                ylabel('Number of Occurrences')
            end

            if WormTrackerPrefs.PauseDuringPlot
            	pause;
            end
        end
        
    end    % END for Frame = 1:FileInfo.NumFrames
    
    % Get rid of invalid tracks
    DeleteTracks = [];
    for i = 1:length(Tracks)
        if length(Tracks(i).Frames) < WormTrackerPrefs.MinTrackLength
            DeleteTracks = [DeleteTracks, i];
        end
    end
    Tracks(DeleteTracks) = [];
    
    % Save Tracks
    SaveFileName = [MovieNames{MN}(1:length(MovieNames{MN})-4) '.mat'];
    save(SaveFileName, 'Tracks');
    
end    % END for i = 1:FileNameSize(1)