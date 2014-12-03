function success = ProcessImageDirectory(curDir, plotting)
    if nargin < 1
        curDir = uigetdir
    end
    if nargin < 2
        plotting = 1;
    end
    cd(curDir) %open the directory of image sequence
    image_files=dir('*.tif'); %get all the tif files

    %get min z projection
    minProj = imread(image_files(1).name);
    for frame_index = 2:min(200, length(image_files) - 1)
        curImage = imread(image_files(frame_index).name);
        minProj = min(minProj, curImage);
    end

    global WormTrackerPrefs
    % Get Tracker default Prefs from Excel file
    ExcelFileName = 'Worm Tracker Preferences';
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
    mask = imread(T{13,2});
    
    global Prefs;

    WorkSheet = 'Analysis Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    Prefs.SampleRate = N(1);
    Prefs.SmoothWinSize = N(2);
    Prefs.StepSize = N(3);
    Prefs.PlotDirection = N(4);
    Prefs.PlotSpeed = N(5);
    Prefs.PlotAngSpeed = N(6);
    Prefs.PirThresh = N(7);
    Prefs.MaxShortRun = N(8);
    Prefs.FFSpeed = N(9);
    Prefs.PixelSize = 1/N(10);
    Prefs.BinSpacing = N(11);
    Prefs.MaxSpeedBin = N(12);
    Prefs.P_MaxSpeed = N(13);
    Prefs.P_TrackFraction = N(14);
    Prefs.P_WriteExcel = N(15);
    
    % Set Matlab's current directory
    Prefs.DefaultPath = T{16,2};
    
    PlotFrameRate = 10;    
    % Display tracking results every 'PlotFrameRate' frames - increase
    % this value (in GUI) to get faster tracking performance


    % Setup figure for plotting tracker results
    % -----------------------------------------
    if plotting
        WTFigH = findobj('Tag', 'WTFIG');
        if isempty(WTFigH)
            WTFigH = figure('Name', 'Tracking Results', ...
                'NumberTitle', 'off', ...
                'Tag', 'WTFIG');
        else
            figure(WTFigH);
        end
    end

    %save subtracted avi
    outputVideo = VideoWriter(fullfile('processed.avi'),'Grayscale AVI');
    outputVideo.FrameRate = 10;
    open(outputVideo)

    % Start Tracker
    % -------------
    Tracks = [];
    
    % Load Voltages
    fid = fopen('LEDVoltages.txt');
    LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
    fclose(fid);
    
    % Analyze Movie
    % -------------
    for frame_index = 1:length(image_files) - 1

        % Get Frame
        curImage = imread(image_files(frame_index).name);
        subtractedImage = curImage - minProj - mask; %subtract min projection
        writeVideo(outputVideo, subtractedImage)

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
        if (plotting && ~mod(frame_index, PlotFrameRate))
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

    close(outputVideo)

    % Get rid of invalid tracks
    DeleteTracks = [];
    for i = 1:length(Tracks)
        if length(Tracks(i).Frames) < WormTrackerPrefs.MinTrackLength
            DeleteTracks = [DeleteTracks, i];
        end
    end
    Tracks(DeleteTracks) = [];

    %go through all the tracks and analyze them
    NumTracks = length(Tracks);
    for TN = 1:NumTracks
        Tracks(TN).Time = Tracks(TN).Frames/Prefs.SampleRate;		% Calculate time of each frame
        Tracks(TN).NumFrames = length(Tracks(TN).Frames);		    % Number of frames

        % Smooth track data by rectangular sliding window of size WinSize;
        Tracks(TN).SmoothX = RecSlidingWindow(Tracks(TN).Path(:,1)', Prefs.SmoothWinSize);
        Tracks(TN).SmoothY = RecSlidingWindow(Tracks(TN).Path(:,2)', Prefs.SmoothWinSize);

        % Calculate Direction & Speed
        Xdif = CalcDif(Tracks(TN).SmoothX, Prefs.StepSize) * Prefs.SampleRate;
        Ydif = -CalcDif(Tracks(TN).SmoothY, Prefs.StepSize) * Prefs.SampleRate;    % Negative sign allows "correct" direction
                                                                                   % cacluation (i.e. 0 = Up/North)
        ZeroYdifIndexes = find(Ydif == 0);
        Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

        Tracks(TN).Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

        NegYdifIndexes = find(Ydif < 0);
        Index1 = find(Tracks(TN).Direction(NegYdifIndexes) <= 0);
        Index2 = find(Tracks(TN).Direction(NegYdifIndexes) > 0);
        Tracks(TN).Direction(NegYdifIndexes(Index1)) = Tracks(TN).Direction(NegYdifIndexes(Index1)) + 180;
        Tracks(TN).Direction(NegYdifIndexes(Index2)) = Tracks(TN).Direction(NegYdifIndexes(Index2)) - 180;

        Tracks(TN).Speed = sqrt(Xdif.^2 + Ydif.^2) * Prefs.PixelSize;		% In mm/sec

        % Calculate angular speed
        Tracks(TN).AngSpeed = CalcAngleDif(Tracks(TN).Direction, Prefs.StepSize) * Prefs.SampleRate;		% in deg/sec

        % Identify Pirouettes (Store as indices in Tracks(TN).Pirouettes)
        Tracks(TN).Pirouettes = IdentifyPirouettes(Tracks(TN));
        
        %Save the LED Voltages for this track
        Tracks(TN).LEDVoltages = LEDVoltages(:, min(Tracks(TN).Frames):max(Tracks(TN).Frames));
    end
    
    % Save Tracks
    SaveFileName = [curDir '\tracks.mat'];
    save(SaveFileName, 'Tracks');
    success = true;
end
