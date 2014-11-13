function DisplayPirouettes

global Prefs;

% Set Matlab's current directory
if exist(Prefs.DefaultPath, 'dir') 
    cd(Prefs.DefaultPath);
end


% Set up for processing
WinSize = 101;          % Window size for smoothing pirouette initiation events and 
                        % pirouette probabilities - essentially defines the
                        % bin size for calculating these values. 
                        % (Measured in Frames.)
                        

            
% Get Tracks File
% ---------------
[FileName, PathName] = uigetfile('*.mat', 'Select Tracks File');
if FileName == 0
    errordlg('No Tracks File Was Selected');
    return;
else
    load([PathName, FileName]);
end
   

% Process Pirouettes Data
% -----------------------
Len = max([Tracks.Frames]);
[TracksHist, t] = hist([Tracks.Time], [1:Len]/Prefs.SampleRate);
TracksHistRecalc = TracksHist;
Pir = [];

for i = 1:length(Tracks)
    Pirouettes = IdentifyPirouettes(Tracks(i));
    if ~isempty(Pirouettes)
        % Collect all Pirouette Initiation Events
        Pir = [Pir, Tracks(i).Time(Pirouettes(:,1))];
        
        % Subtract Pirouette times (including if still in short run) from
        % tracks histogram (states in which worms are unable to initiate pirouettes)
        NumPirouettes = length(Pirouettes(:,1));
        for j = 1:NumPirouettes - 1
            MaxIndex = min(Pirouettes(j,2) + round(Prefs.MaxShortRun*Prefs.SampleRate), Pirouettes(j+1,1) - 1);
            if MaxIndex > 0
                TracksHistRecalc(Tracks(i).Frames(Pirouettes(j,1)+1:MaxIndex)) = ...
                    TracksHistRecalc(Tracks(i).Frames(Pirouettes(j,1)+1:MaxIndex)) - 1;
            end
        end
        MaxIndex = min(Pirouettes(NumPirouettes,2) + round(Prefs.MaxShortRun*Prefs.SampleRate), Tracks(i).NumFrames);
        if MaxIndex > 0
            TracksHistRecalc(Tracks(i).Frames(Pirouettes(NumPirouettes,1)+1:MaxIndex)) = ...
                TracksHistRecalc(Tracks(i).Frames(Pirouettes(NumPirouettes,1)+1:MaxIndex)) - 1;
        end
    end
end

PirHist = hist(Pir, t);


% Plot Results
% ------------
PirFigH = findobj('Tag', 'PIRFIG');
if isempty(PirFigH)
    PirFigH = figure('Name', 'Pirouette Initiation Events Throughout Experiment', ...
    	'NumberTitle', 'off', ...
    	'Tag', 'PIRFIG');
else
    figure(PirFigH);
end


% Plot Tracks Histogram
subplot(4,1,1), bar(t, TracksHist);
ylabel('No. Tracks');
title('Number of Worms Tracked vs. Time');

% Plot Recaculated Tracks Histogram
subplot(4,1,2), bar(t, TracksHistRecalc);
ylabel('No. Worms');
title('Number of Worms With potential to Pirouette vs. Time');

% Plot Pirouette Initiation Events
PirHistWin = WinSize;
SmoothPirHist = RecSlidingWindow(PirHist, PirHistWin);
figure(PirFigH);
subplot(4,1,3), plot(t, SmoothPirHist);
% subplot(4,1,3), bar(t, PirHist);
ylabel('Frequency');
title('Pirouette Initiation Event Frequency');
grid on;
xAxisScale = xlim;

% Plot Pirouette Initiation Probability
PirProbWin = WinSize;
NoWormIndices = find(TracksHistRecalc == 0);
TracksHistRecalc(NoWormIndices) = [];
PirHist(NoWormIndices) = [];
tNoWorm = t;
tNoWorm(NoWormIndices) = [];
HistLen = length(tNoWorm);
PirInitProb = PirHist./TracksHistRecalc;
SmoothPirInitProb = RecSlidingWindow(PirInitProb, PirProbWin);
figure(PirFigH);
subplot(4,1,4), plot(tNoWorm, SmoothPirInitProb);
ylabel('Probability');
xlabel('Time (Sec)');
title('Pirouette Initiation Probability');
grid on;
xlim([xAxisScale]);



