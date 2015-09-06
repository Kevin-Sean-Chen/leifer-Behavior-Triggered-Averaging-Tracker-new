%%
% analysis_mode 'all' does tracking, analysis and saves centerlines
% analysis_mode 'analysis' skips the tracking, does analysis and saves centerlines
% analysis_mode 'track_plot' tracks and plots (no eigen worms)
% analysis_mode 'continue' tracks (no eigen worms) the folders without tracks.mat
function success = ProcessImageDirectory(curDir, plotting, plotting_index, analysis_mode)
    if nargin < 1
        curDir = uigetdir
    end
    if nargin < 2
        plotting = 0;
    end
    if nargin < 3
        plotting_index = 0;
    end
    if nargin < 4
        analysis_mode = 'track_plot';
    end
    cd(curDir) %open the directory of image sequence
    
    if exist('tracks.mat', 'file') == 2
%     if strcmp(analysis_mode, 'analysis')
        if strcmp(analysis_mode, 'continue')
            %track already exists, skip analysis
            success = true;
            return
        elseif strcmp(analysis_mode, 'analysis')
            load('tracks.mat')
        end
    end
    
    image_files=dir('*.tif'); %get all the tif files
    %image_files=dir('*.jpg'); %get all the jpg files
    
    [~, ComputerName] = system('hostname');
    
    global WormTrackerPrefs
    % Get Tracker default Prefs from Excel file
    ExcelFileName = 'Worm Tracker Preferences';
    WorkSheet = 'Tracker Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    
    for computer_index = 1:size(T,2)
        if strcmp(T{1,computer_index}, strtrim(ComputerName))
            break
        end
    end
    computer_index = computer_index - 1; % the first column does not count
    
    WormTrackerPrefs.MinWormArea = N(1,computer_index);
    WormTrackerPrefs.MaxWormArea = N(2,computer_index);
    WormTrackerPrefs.MaxDistance = N(3,computer_index);
    WormTrackerPrefs.SizeChangeThreshold = N(4,computer_index);
    WormTrackerPrefs.MinTrackLength = N(5,computer_index);
    WormTrackerPrefs.AutoThreshold = N(6,computer_index);
    WormTrackerPrefs.CorrectFactor = N(7,computer_index);
    WormTrackerPrefs.ManualSetLevel = N(8,computer_index);
    WormTrackerPrefs.DarkObjects = N(9,computer_index);
    WormTrackerPrefs.PlotRGB = N(10,computer_index);
    WormTrackerPrefs.PauseDuringPlot = N(11,computer_index);
    WormTrackerPrefs.PlotObjectSizeHistogram = N(12,computer_index);
    
    if exist(T{14,computer_index+1}, 'file')
       mask = imread(T{14,computer_index+1}); 
    else
       mask = 0;
    end
    
    %WormTrackerPrefs.ManualThresholdMedian = N(14,computer_index);
    WormTrackerPrefs.MaxObjects = N(14,computer_index);
    
    global Prefs;

    WorkSheet = 'Analysis Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
        
    for computer_index = 1:size(T,2)
        if strcmp(T{1,computer_index}, strtrim(ComputerName))
            break
        end
    end
    computer_index = computer_index - 1; % the first column does not count
    
    Prefs.SampleRate = N(1,computer_index);
    Prefs.SmoothWinSize = N(2,computer_index);
    Prefs.StepSize = N(3,computer_index);
    Prefs.PlotDirection = N(4,computer_index);
    Prefs.PlotSpeed = N(5,computer_index);
    Prefs.PlotAngSpeed = N(6,computer_index);
    Prefs.PirThresh = N(7,computer_index);
    Prefs.MaxShortRun = N(8,computer_index);
    Prefs.FFSpeed = N(9,computer_index);
    Prefs.PixelSize = 1/N(10,computer_index);
    Prefs.BinSpacing = N(11,computer_index);
    Prefs.MaxSpeedBin = N(12,computer_index);
    Prefs.P_MaxSpeed = N(13,computer_index);
    Prefs.P_TrackFraction = N(14,computer_index);
    Prefs.P_WriteExcel = N(15,computer_index);
    Prefs.MinDisplacement = N(17,computer_index);
    Prefs.PirSpeedThresh = N(18,computer_index);
    Prefs.EccentricityThresh = N(19,computer_index);
    Prefs.PauseSpeedThresh = N(20,computer_index);
    Prefs.MinPauseDuration = N(21,computer_index);    
    % Set Matlab's current directory
    Prefs.DefaultPath = T{17,computer_index+1};
    
    PlotFrameRate = 7;    
    % Display tracking results every 'PlotFrameRate' frames - increase
    % this value (in GUI) to get faster tracking performance


    % Setup figure for plotting tracker results
    % -----------------------------------------
    if plotting
        WTFigH = findobj('Tag', ['WTFIG', num2str(plotting_index)]);
        if isempty(WTFigH)
            WTFigH = figure('Name', 'Tracking Results', ...
                'NumberTitle', 'off', ...
                'Tag', ['WTFIG', num2str(plotting_index)]);
        else
            figure(WTFigH);
        end
    end
    
    % Load Voltages
    fid = fopen('LEDVoltages.txt');
    LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
    fclose(fid);
    
    %get median z projection
    medianProj = imread(image_files(1).name);
    medianProjCount = min(20, length(image_files) - 1);
    medianProj = zeros(size(medianProj,1), size(medianProj,2), medianProjCount);
    %medianIntensities = zeros(medianProjCount,1);
    for frame_index = 1:medianProjCount
        curImage = imread(image_files(floor((length(image_files)-1)*frame_index/medianProjCount)).name);
        medianProj(:,:,frame_index) = curImage;
        %curImage = curImage(872:1072,1196:1396);
        %medianIntensities(frame_index,1) = median(curImage(:));
    end
    medianProj = median(medianProj, 3);
    %medianIntensities = median(medianIntensities); %used to account for non-uniform light intensities over time
    medianProj = uint8(medianProj);
    
    if ~strcmp(analysis_mode, 'analysis')
        % Start Tracker
        % -------------
        Tracks = [];
        
        % Analyze Movie
        % -------------
        for frame_index = 1:length(image_files) - 1

            % Get Frame
            curImage = imread(image_files(frame_index).name);
            %subImage = curImage(872:1072,1196:1396);
            %imageBackground = uint8(median(subImage(:)) - WormTrackerPrefs.ManualThresholdMedian);
            subtractedImage = curImage - medianProj - mask; %subtract median projection   - imageBackground
            %writeVideo(outputVideo, subtractedImage)

            % Convert frame to a binary image 
            if WormTrackerPrefs.AutoThreshold       % use auto thresholding
                Level = graythresh(subtractedImage) + WormTrackerPrefs.CorrectFactor;
                Level = max(min(Level,1) ,0);
            else
                Level = WormTrackerPrefs.ManualSetLevel;
            end
            NUM = WormTrackerPrefs.MaxObjects + 1;
            while (NUM > WormTrackerPrefs.MaxObjects)
                if WormTrackerPrefs.DarkObjects
                    BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
                else
                    BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
                end

                %imwrite(subtractedImage, 'test.tif', 'tif');
                %writeVideo(outputVideo, double(BW))

                % Identify all objects
                [L,NUM] = bwlabel(BW);
                Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
            end
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
                %find the closest worm still being tracked
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
                    Tracks(ActiveTracks(i)).WormIndex = [Tracks(ActiveTracks(i)).WormIndex, WormIndices(MinIndex)];
                    WormIndices(MinIndex) = [];
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
                Tracks(Index).WormIndex = WormIndices(i);
            end

            % Display every PlotFrameRate'th frame
            if (0 && plotting && ~mod(frame_index, PlotFrameRate))

    %             RGB = label2rgb(L, @jet, 'k');

    %             PlotFrame(WTFigH, RGB, Tracks);
    %             FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
    %             set(WTFigH, 'Name', FigureName);

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

    %             writeVideo(outputVideo, getframe(WTFigH));
            end
        end    % END for Frame = 1:FileInfo.NumFrames
    end
    
    
    %%%%%% Analysis %%%%%%
    % Get rid of invalid tracks
    DeleteTracks = [];
    for i = 1:length(Tracks)
        if length(Tracks(i).Frames) < WormTrackerPrefs.MinTrackLength
            DeleteTracks = [DeleteTracks, i];
        else
            %find the maximum displacement from the first time point.
            %correct for dirts that don't move
            position_relative_to_start = transpose(Tracks(i).Path - repmat(Tracks(i).Path(1,:),size(Tracks(i).Path,1),1));
            euclideian_distances_relative_to_start = sqrt(sum(position_relative_to_start.^2,1)); %# The two-norm of each column
            if max(euclideian_distances_relative_to_start) < Prefs.MinDisplacement
                DeleteTracks = [DeleteTracks, i];
            end
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
        
        Tracks(TN).SmoothSpeed = smoothts(Tracks(TN).Speed, 'g', Prefs.StepSize, Prefs.StepSize);		% In mm/sec
        %AngleChanges = CalcAngleDif(Tracks(TN).Direction, Prefs.StepSize);
        AngleChanges = CalcAngleDif(Tracks(TN).Direction, Prefs.StepSize);
        
        % Calculate angular speed
        Tracks(TN).AngSpeed = AngleChanges * Prefs.SampleRate;		% in deg/sec
        
        Tracks(TN).BackwardAcc = CalcBackwardAcc(Tracks(TN).Speed, AngleChanges, Prefs.StepSize);		% in mm/sec^2

        %Find Pauses
        Tracks(TN).Pauses = IdentifyPauses(Tracks(TN));
                
        % Identify Pirouettes (Store as indices in Tracks(TN).Pirouettes)
        Tracks(TN).Pirouettes = IdentifyPirouettes(Tracks(TN));
 
        % Identify Omegas (Store as indices in Tracks(TN).OmegaTurns)
        Tracks(TN).OmegaTurns = IdentifyOmegaTurns(Tracks(TN));
 
        % Identify Runs (Store as indices in Tracks(TN).Runs)
        Tracks(TN).Runs = IdentifyRuns(Tracks(TN));

        %Save the LED Voltages for this track
        Tracks(TN).LEDVoltages = LEDVoltages(:, min(Tracks(TN).Frames):max(Tracks(TN).Frames));
    end
    
    % Save Tracks
    saveFileName = [curDir '\tracks.mat'];
    save(saveFileName, 'Tracks');
    AutoSave(curDir, Prefs.DefaultPath);
    
    Tracks = Find_Centerlines(Tracks, image_files, medianProj, mask);
    
    % Save Tracks
    saveFileName = [curDir '\tracks.mat'];
    save(saveFileName, 'Tracks');
    AutoSave(curDir, Prefs.DefaultPath);
    
    if plotting
        %save subtracted avi
        outputVideo = VideoWriter(fullfile('processed'),'MPEG-4');
        outputVideo.FrameRate = 14;
        open(outputVideo)
        

        %plotting reversals

        for frame_index = 1:length(image_files) - 1

            % Get Frame
            curImage = imread(image_files(frame_index).name);
            subtractedImage = curImage - uint8(medianProj) - mask; %subtract median projection  - imageBackground
            if WormTrackerPrefs.AutoThreshold       % use auto thresholding
                Level = graythresh(subtractedImage) + WormTrackerPrefs.CorrectFactor;
                Level = max(min(Level,1) ,0);
            else
                Level = WormTrackerPrefs.ManualSetLevel;
            end
            % Convert frame to a binary image 
            NUM = WormTrackerPrefs.MaxObjects + 1;
            while (NUM > WormTrackerPrefs.MaxObjects)
                if WormTrackerPrefs.DarkObjects
                    BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
                else
                    BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
                end

                % Identify all objects
                [L,NUM] = bwlabel(BW);
                Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
            end

            PlotFrame(WTFigH, double(BW), Tracks, frame_index, LEDVoltages(frame_index));
            FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
            set(WTFigH, 'Name', FigureName);

            writeVideo(outputVideo, getframe(WTFigH));
        end
        close(outputVideo) 
    end


    success = true;
end
