% global WormTrackerPrefs
% % Get Tracker default Prefs from Excel file
% ExcelFileName = 'Worm Tracker Preferences';
% WorkSheet = 'Tracker Prefs';
% [N, T, D] = xlsread(ExcelFileName, WorkSheet);
% WormTrackerPrefs.MinWormArea = N(1);
% WormTrackerPrefs.MaxWormArea = N(2);
% WormTrackerPrefs.MaxDistance = N(3);
% WormTrackerPrefs.SizeChangeThreshold = N(4);
% WormTrackerPrefs.MinTrackLength = N(5);
% WormTrackerPrefs.AutoThreshold = N(6);
% WormTrackerPrefs.CorrectFactor = N(7);
% WormTrackerPrefs.ManualSetLevel = N(8);
% WormTrackerPrefs.DarkObjects = N(9);
% WormTrackerPrefs.PlotRGB = N(10);
% WormTrackerPrefs.PauseDuringPlot = N(11);
% WormTrackerPrefs.PlotObjectSizeHistogram = N(12);
% mask = imread(T{13,2});
% %WormTrackerPrefs.ManualThresholdMedian = N(14);
% WormTrackerPrefs.MaxObjects = N(14);
% 
% global Prefs;
% 
% WorkSheet = 'Analysis Prefs';
% [N, T, D] = xlsread(ExcelFileName, WorkSheet);
% Prefs.SampleRate = N(1);
% Prefs.SmoothWinSize = N(2);
% Prefs.StepSize = N(3);
% Prefs.PlotDirection = N(4);
% Prefs.PlotSpeed = N(5);
% Prefs.PlotAngSpeed = N(6);
% Prefs.PirThresh = N(7);
% Prefs.MaxShortRun = N(8);
% Prefs.FFSpeed = N(9);
% Prefs.PixelSize = 1/N(10);
% Prefs.BinSpacing = N(11);
% Prefs.MaxSpeedBin = N(12);
% Prefs.P_MaxSpeed = N(13);
% Prefs.P_TrackFraction = N(14);
% Prefs.P_WriteExcel = N(15);
% Prefs.MinDisplacement = N(17);
% Prefs.PirSpeedThresh = N(18);
% Prefs.EccentricityThresh = N(19);
% Prefs.PauseSpeedThresh = N(20);
% Prefs.MinPauseDuration = N(21);    
% % Set Matlab's current directory


TN = 4;

hiResPos = [hiResxPos, hiResyPos];

Tracks(TN).Path = SubSampleTrack(hiResPos, hiResFrameTime, 14, 1);
Tracks(TN).Frames = 1:size(Tracks(TN).Path,1);
Tracks(TN).Time = 0:1/14:(size(Tracks(TN).Path,1)-1)/14;
Tracks(TN).NumFrames = size(Tracks(TN).Path,1);
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

Tracks(TN).Speed = sqrt(Xdif.^2 + Ydif.^2);		% In mm/sec

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

% Identify Runs (Store as indices in Tracks(TN).Runs)
Tracks(TN).Runs = IdentifyRuns(Tracks(TN));

Tracks(TN).Behavior = SubSampleTrack(ethoTrack, hasPointsTime, 14, 0);
Tracks(TN).Behavior = Tracks(TN).Behavior(1:size(Tracks(TN).Path,1));

my_markers = 'x.^*';
my_colors = {'b', 'g', 'y', 'r', 'm', 'c'};

figure
hold on
for pause_index = 1:size(Tracks(TN).Pauses,1)
    plot(Tracks(TN).Path(Tracks(TN).Pauses(pause_index,1):Tracks(TN).Pauses(pause_index,2),1),Tracks(TN).Path(Tracks(TN).Pauses(pause_index,1):Tracks(TN).Pauses(pause_index,2),2),'m*')
end
for reversal_index = 1:size(Tracks(TN).Pirouettes,1)
    plot(Tracks(TN).Path(Tracks(TN).Pirouettes(reversal_index,1):Tracks(TN).Pirouettes(reversal_index,2),1),Tracks(TN).Path(Tracks(TN).Pirouettes(reversal_index,1):Tracks(TN).Pirouettes(reversal_index,2),2),'cx')
end

for path_index = 1:size(Tracks(TN).Path,1)
    if ~isnan(Tracks(TN).Behavior(path_index))
        plot(Tracks(TN).Path(path_index,1),Tracks(TN).Path(path_index,2), [my_colors{Tracks(TN).Behavior(path_index)+2}, '.'])
    end
end
hold off

h = findobj('Color','b');
g = findobj('Color','g');
i = findobj('Color','y');
j = findobj('Color','r');
k = findobj('Color','m');
l = findobj('Color','c'); 
v = [h(1) g(1) i(1) j(1) k(1) l(1)];
legend(v, {'reverse','pause','forward','turn','pause','reversal'})