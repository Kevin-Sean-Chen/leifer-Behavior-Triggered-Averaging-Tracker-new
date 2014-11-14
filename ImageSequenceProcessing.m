curDir = 'C:\Data\20141112\Data20141112_184855_5maxV_2s';
cd(curDir) %open the directory of image sequence
image_files=dir('*.tif'); %get all the tif files

%get min z projection
minProj = imread(image_files(1).name);
for frame_index = 2:min(200, length(image_files) - 1)
    curImage = imread(image_files(frame_index).name);
    minProj = min(minProj, curImage);
end

%save subtracted avi
% outputVideo = VideoWriter(fullfile('processed.avi'),'Grayscale AVI');
% outputVideo.FrameRate = 10;
% outputVideo.FileFormat
% open(outputVideo)
% 
% for frame_index = 1:length(image_files) - 1
%     curImage = imread(image_files(frame_index).name);
%     subtractedImage = curImage - minProj;
%     writeVideo(outputVideo, subtractedImage)
%     frame_index
% end
% close(outputVideo)


global WormTrackerPrefs
% Get Tracker default Prefs from Excel file
ExcelFileName = 'C:\Matlab Functions\Worm Tracker Preferences';
WorkSheet = 'Tracker Prefs';
[N, T, D] = xlsread(ExcelFileName, WorkSheet);
WormTrackerPrefs.MinWormArea = N(1);
WormTrackerPrefs.MaxWormArea = N(2);
WormTrackerPrefs.MaxDistance = N(3);
WormTrackerPrefs.SizeChangeThreshold = N(4);
WormTrackerPrefs.MinTrackLength = N(5);
WormTrackerPrefs.AutoThreshold = N(6);
WormTrackerPrefs.CorrectFactor = N(7);
WormTrackerPrefs.ManualSetLevel = N(8);
WormTrackerPrefs.DarkObjects = N(9);
WormTrackerPrefs.PlotRGB = N(10);
WormTrackerPrefs.PauseDuringPlot = N(11);
WormTrackerPrefs.PlotObjectSizeHistogram = N(12);

PlotFrameRate = 10;    
% Display tracking results every 'PlotFrameRate' frames - increase
% this value (in GUI) to get faster tracking performance

% Get movies to track
% -------------------
% MovieNames = {};
% MovieNames{length(MovieNames)+1} = ['processed.avi'];


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

Tracks = [];

% Analyze Movie
% -------------
for frame_index = 1:length(image_files) - 1

    % Get Frame
    curImage = imread(image_files(frame_index).name);
    subtractedImage = curImage - minProj;

    % Convert frame to a binary image 
    if WormTrackerPrefs.AutoThreshold       % use auto thresholding
        Level = graythresh(subtractedImage) + WormTrackerPrefs.CorrectFactor;
        Level = max(min(Level,1) ,0);
    else
        Level = WormTrackerPrefs.ManualSetLevel;
    end
    if WormTrackerPrefs.DarkObjects
        BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
    else
        BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
    end

    % Identify all objects
    [L,NUM] = bwlabel(BW);
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
            Tracks(ActiveTracks(i)).Frames = [Tracks(ActiveTracks(i)).Frames, frame_index];
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
        Tracks(Index).Frames = frame_index;
        Tracks(Index).Size = WormSizes(i);
        Tracks(Index).LastSize = WormSizes(i);
        Tracks(Index).FilledArea = WormFilledAreas(i);
        Tracks(Index).Eccentricity = WormEccentricities(i);
    end

    % Display every PlotFrameRate'th frame
    if ~mod(frame_index, PlotFrameRate)
        PlotFrame(WTFigH, subtractedImage, Tracks);
        FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
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
SaveFileName = [curDir '\tracks.mat'];
save(SaveFileName, 'Tracks');
