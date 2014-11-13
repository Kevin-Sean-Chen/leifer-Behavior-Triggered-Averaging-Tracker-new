function ParalysisTracker(MovieName)

global P_TrackerPrefs
global VideoPrefs

% Get Paralysis Tracker Prefs from Excel file (First run only)
if MovieName(length(MovieName)-4) == '1'
    ExcelFileName = 'C:\Matlab Functions\Worm Tracker Preferences';
    WorkSheet = 'Tracker Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    P_TrackerPrefs.MinWormArea = N(1);
    P_TrackerPrefs.MaxWormArea = N(2);
    P_TrackerPrefs.MaxDistance = N(3);
    P_TrackerPrefs.SizeChangeThreshold = N(4);
    P_TrackerPrefs.MinTrackLength = N(5);
    P_TrackerPrefs.AutoThreshold = N(6);
    P_TrackerPrefs.CorrectFactor = N(7);
    P_TrackerPrefs.ManualSetLevel = N(8);
    P_TrackerPrefs.DarkObjects = N(9);
    P_TrackerPrefs.PlotFrameRate = 10;

    WorkSheet = 'Analysis Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    P_TrackerPrefs.SmoothWinSize = N(2);
    P_TrackerPrefs.StepSize = N(3);
    P_TrackerPrefs.PixelSize = 1/N(10);
    P_TrackerPrefs.P_MaxSpeed = N(13);
    P_TrackerPrefs.P_TrackFraction = N(14);
    P_TrackerPrefs.P_WriteExcel = N(15);
end

Tracks = [];



% Get AVI movie for analysis
% --------------------------
FileInfo = aviinfo(MovieName);

WTFigH = findobj('Tag', 'WTFIG');
if isempty(WTFigH)
    WTFigH = figure('Name', 'Tracking Results', ...
	    'NumberTitle', 'off', ...
	    'Tag', 'WTFIG');
else
    figure(WTFigH);
end


% Analyze Movie
% -------------
for Frame = 1:FileInfo.NumFrames

    % Get Frame
    Mov = aviread(MovieName, Frame);
    
    % Convert frame to a binary image
    if P_TrackerPrefs.AutoThreshold       % use auto thresholding
        Level = graythresh(Mov.cdata) + P_TrackerPrefs.CorrectFactor;
    else
        Level = P_TrackerPrefs.ManualSetLevel;
    end
    if P_TrackerPrefs.DarkObjects
        BW = ~im2bw(Mov.cdata, Level);  % For tracking dark objects on a bright background
    else
        BW = im2bw(Mov.cdata, Level);  % For tracking bright objects on a dark background
    end
    
    % Identify all objects
    [L,NUM] = bwlabel(BW);
    STATS = regionprops(L, {'Area', 'Centroid'});
    
    % Identify all worms by size, get their centroid coordinates
    WormIndices = find([STATS.Area] > P_TrackerPrefs.MinWormArea & [STATS.Area] < P_TrackerPrefs.MaxWormArea);
    NumWorms = length(WormIndices);
    WormCentroids = [STATS(WormIndices).Centroid];
    WormCoordinates = [WormCentroids(1:2:2*NumWorms)', WormCentroids(2:2:2*NumWorms)'];
    WormSizes = [STATS(WormIndices).Area];
    
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
        if (MinVal <= P_TrackerPrefs.MaxDistance) & ...
                (abs(WormSizes(MinIndex) - Tracks(ActiveTracks(i)).LastSize) < P_TrackerPrefs.SizeChangeThreshold)
            Tracks(ActiveTracks(i)).Path = [Tracks(ActiveTracks(i)).Path; WormCoordinates(MinIndex, :)];
            Tracks(ActiveTracks(i)).LastCoordinates = WormCoordinates(MinIndex, :);
            Tracks(ActiveTracks(i)).Frames = [Tracks(ActiveTracks(i)).Frames, Frame];
            Tracks(ActiveTracks(i)).Size = [Tracks(ActiveTracks(i)).Size, WormSizes(MinIndex)];
            Tracks(ActiveTracks(i)).LastSize = WormSizes(MinIndex);
            WormCoordinates(MinIndex,:) = [];
            WormSizes(MinIndex) = [];
        else
            Tracks(ActiveTracks(i)).Active = 0;
            if length(Tracks(ActiveTracks(i)).Frames) < P_TrackerPrefs.MinTrackLength
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
    end
    
    % Display every PlotFrameRate'th frame
    if ~mod(Frame, P_TrackerPrefs.PlotFrameRate)
        PlotFrame(WTFigH, Mov, Tracks);
        FigureName = ['Tracking Results for Frame ', num2str(Frame)];
        set(WTFigH, 'Name', FigureName);
    end

end    % END for Frame = 1:FileInfo.NumFrames

% Get rid of invalid tracks
DeleteTracks = [];
for i = 1:length(Tracks)
    if length(Tracks(i).Frames) < P_TrackerPrefs.MinTrackLength
        DeleteTracks = [DeleteTracks, i];
    end
end
Tracks(DeleteTracks) = [];

% Save Tracks
TracksSaveFileName = [MovieName(1:length(MovieName)-4) '.mat'];
save(TracksSaveFileName, 'Tracks');




% Analyze Paralysis
% -----------------

% Setup display to report results....
disp(' ')
disp(' ')
disp(sprintf('File Name\t\t\tFraction Paralyzed\t\tTotal # Tracks\t\t# Paralyzed Tracks\t\tMean Speed (mm/s)\t\t# Speed Measurements'))
disp('-----------------------------------------------------------------------------------------------------------------------------------')

% Setup file for saving data (only on first run)
if P_TrackerPrefs.P_WriteExcel
    SaveFileName = [VideoPrefs.savePath 'Analysis Results.xls'];
    if ~exist(SaveFileName, 'file')
        xlswrite(SaveFileName, {'File Name','Fraction Paralyzed','Total # Tracks', ...
            '# Paralyzed Tracks','Mean Speed (mm/s)','# Speed Measurements'});
    end
end

P_Total = 0;
P_NumTracks = 0;

for TN = 1:length(Tracks)

	% Smooth track data by rectangular sliding window of size WinSize;
	Tracks(TN).SmoothX = RecSlidingWindow(Tracks(TN).Path(:,1)', P_TrackerPrefs.SmoothWinSize);
	Tracks(TN).SmoothY = RecSlidingWindow(Tracks(TN).Path(:,2)', P_TrackerPrefs.SmoothWinSize);

	% Calculate Speed
	Xdif = CalcDif(Tracks(TN).SmoothX, P_TrackerPrefs.StepSize) * VideoPrefs.SampleRate;
	Ydif = -CalcDif(Tracks(TN).SmoothY, P_TrackerPrefs.StepSize) * VideoPrefs.SampleRate;    
            % Negative sign allows "correct" direction cacluation (i.e. 0 = Up/North)
  	Tracks(TN).Speed = sqrt(Xdif.^2 + Ydif.^2) * P_TrackerPrefs.PixelSize;		% In mm/sec

    if sum(Tracks(TN).Speed < P_TrackerPrefs.P_MaxSpeed)/length(Tracks(TN).Speed) ...
            > P_TrackerPrefs.P_TrackFraction
        P_Total = P_Total + length(Tracks(TN).Speed);
        P_NumTracks = P_NumTracks + 1;
    end

end

allpointsout = [Tracks.Speed]';
MeanSpeed = mean(allpointsout);
NumPts = length(allpointsout);
FractionParalyzed = P_Total/length([Tracks.Frames]);
NumTracks = length(Tracks);

MovieNameStart = find(MovieName == '\', 1, 'last');
MName = MovieName(MovieNameStart+1:length(MovieName));

Spacer = '';
for j = 1:26-length(MName)
    Spacer = [Spacer, ' '];
end
disp(sprintf('%s%s%1.3f\t\t\t\t\t%4.0f\t\t\t\t%4.0f\t\t\t\t\t\t%1.3f\t\t\t%15.0f', ...
    MName, Spacer, FractionParalyzed, NumTracks, P_NumTracks, MeanSpeed, NumPts))
disp('')

if P_TrackerPrefs.P_WriteExcel
    [num, txt, raw]= xlsread(SaveFileName);
    xlswrite(SaveFileName, {MName, FractionParalyzed, NumTracks, ...
        P_NumTracks, MeanSpeed, NumPts}, 1, ['A' num2str(size(raw, 1)+1)]);
end

