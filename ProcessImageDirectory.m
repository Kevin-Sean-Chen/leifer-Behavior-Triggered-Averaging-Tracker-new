%%
% analysis_mode 'all' does tracking, analysis and saves centerlines
% analysis_mode 'analysis' skips the tracking, does analysis and saves centerlines
% analysis_mode 'track_plot' tracks and plots (no eigen worms)
% analysis_mode 'continue' tracks (no eigen worms) the folders without tracks.mat
function success = ProcessImageDirectory(curDir, plotting, plotting_index, analysis_mode)
% tracks and extracts the centerlines for all the images in a directory

    %% STEP 1: initialize %%
    number_of_images_for_median_projection = 20;
    if nargin < 1
        %ask user to select a directory if it is not given
        curDir = uigetdir
    end
    if nargin < 2
        %default is to plot
        plotting = 0;
    end
    if nargin < 3
        plotting_index = 0;
    end
    if nargin < 4
        %default mode
        analysis_mode = 'all';
    end
    cd(curDir) %open the directory of image sequence
    
    %% STEP 2: Load the analysis preferences from Excel %%
    [~, ComputerName] = system('hostname'); %get the computer name
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
        %get the mask
       mask = imread(T{14,computer_index+1}); 
    else
       mask = 0;
    end
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
    Prefs.MaxBackwardsFrames = N(22,computer_index) * Prefs.SampleRate;
    Prefs.DefaultPath = T{17,computer_index+1};
    
    %% STEP 3: See if a track file exists, if it does, there are some options that use them %%
    if exist('tracks.mat', 'file') == 2
        if strcmp(analysis_mode, 'continue')
            %track already exists, skip analysis
            success = true;
            return
        elseif strcmp(analysis_mode, 'analysis')
            load('tracks.mat')
        end
    end
    
    %% STEP 4: Set up plotting if we need to %%
    % Display tracking results every 'PlotFrameRate' frames - increase
    % this value (in GUI) to get faster tracking performance
    PlotFrameRate = 7;  
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
    
    %% STEP 5: Load images and other properties from the directory %%
    % Get all the tif file names (probably jpgs)
    image_files=dir('*.tif'); 
    % Load Voltages
    fid = fopen('LEDVoltages.txt');
    LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
    fclose(fid);
    
    %% STEP 6: Get the median z projection %%
    medianProj = imread(image_files(1).name);
    [x_resolution, y_resolution] = size(medianProj);
    medianProjCount = min(number_of_images_for_median_projection, length(image_files) - 1); 
    medianProj = zeros(size(medianProj,1), size(medianProj,2), medianProjCount);
    for frame_index = 1:medianProjCount
        curImage = imread(image_files(floor((length(image_files)-1)*frame_index/medianProjCount)).name);
        medianProj(:,:,frame_index) = curImage;
    end
    medianProj = median(medianProj, 3);
    medianProj = uint8(medianProj);
    
    %% STEP 7: TRACKING %%
    if ~strcmp(analysis_mode, 'analysis')
        % Start Tracker
        Tracks = [];
        
        % Analyze Movie
        for frame_index = 1:length(image_files) - 1
            % Get Frame
            curImage = imread(image_files(frame_index).name);
            subtractedImage = curImage - medianProj - mask;

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
                
                % Identify all objects
                [L,NUM] = bwlabel(BW);
                Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
            end
            STATS = regionprops(L, {'Area', 'Centroid', 'FilledArea', 'Eccentricity', 'Extrema'});

            % Identify all worms by size
            WormIndices = find([STATS.Area] > WormTrackerPrefs.MinWormArea & ...
                [STATS.Area] < WormTrackerPrefs.MaxWormArea);
            
            % Find and ignore the blobs touching the edge
            all_extrema = reshape([STATS.Extrema], 8, 2, []);
            x_extrema = squeeze(all_extrema(:,2,:));
            y_extrema = squeeze(all_extrema(:,1,:));
            x_extrema_left_border = arrayfun(@(x) le(x,1), x_extrema);
            x_extrema_right_border = arrayfun(@(x) ge(x,x_resolution), x_extrema);
            y_extrema_top_border = arrayfun(@(y) le(y,1), y_extrema);          
            y_extrema_bottom_border = arrayfun(@(y) ge(y,y_resolution), y_extrema);
            
            x_extrema_left_border = sum(x_extrema_left_border, 1);
            x_extrema_right_border = sum(x_extrema_right_border, 1);
            y_extrema_top_border = sum(y_extrema_top_border, 1) >= 1;
            y_extrema_bottom_border = sum(y_extrema_bottom_border, 1);
            frames_on_border = bsxfun(@or, x_extrema_left_border, x_extrema_right_border);
            frames_on_border = bsxfun(@or, frames_on_border, y_extrema_top_border);
            frames_on_border = bsxfun(@or, frames_on_border, y_extrema_bottom_border);
            
            WormIndices = intersect(WormIndices, find(~frames_on_border));
            
            % get their centroid coordinates
            NumWorms = length(WormIndices);
            WormCentroids = [STATS(WormIndices).Centroid];
            WormCoordinates = [WormCentroids(1:2:2*NumWorms)', WormCentroids(2:2:2*NumWorms)'];
            WormSizes = [STATS(WormIndices).Area];
            WormFilledAreas = [STATS(WormIndices).FilledArea];
            WormEccentricities = [STATS(WormIndices).Eccentricity];

            % Track worms 
            if isempty(Tracks)
                ActiveTracks = [];
            else
                ActiveTracks = find([Tracks.Active]);
            end

            % Update active tracks with new coordinates
            for i = 1:length(ActiveTracks)
                %find the closest worm still being tracked, and update it
                DistanceX = WormCoordinates(:,1) - Tracks(ActiveTracks(i)).LastCoordinates(1);
                DistanceY = WormCoordinates(:,2) - Tracks(ActiveTracks(i)).LastCoordinates(2);
                Distance = sqrt(DistanceX.^2 + DistanceY.^2);
                [MinVal, MinIndex] = min(Distance);
                if ~isempty(MinVal) && (MinVal <= WormTrackerPrefs.MaxDistance) && ...
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
            frame_index
        end
    end
    
    %% STEP 8: Post-Track Filtering to get rid of invalid tracks %%
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
    
    %% STEP 9: Go through all the tracks and analyze them %% 
    
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
    
    %% STEP 10: save each worms' images %%
    save_individual_worm_images(Tracks, image_files, medianProj, mask, curDir);
        
    %% STEP 11: get the worm's centerlines %%
    Tracks = Find_Centerlines(Tracks, curDir);
    
    %% STEP 12: Save the tracks %%
    saveFileName = [curDir '\tracks.mat'];
    save(saveFileName, 'Tracks');
    AutoSave(curDir, Prefs.DefaultPath);
    
    %% STEP XX: plot the tracks
    individual_worm_videos(Tracks, curDir);
    
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

    %% STEP FINAL: return 
    success = true;
end
