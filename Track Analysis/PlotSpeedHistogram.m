function PlotSpeedHistogram(Mode)

global Prefs
global Tracks;

SaveTracks = Tracks;  % Store Tracks Data for current movie...       

Bins = [Prefs.BinSpacing/2:Prefs.BinSpacing:Prefs.MaxSpeedBin];

if strcmp(Mode, 'Multiple')
    % Prompt user for number of movies spanned by tracks
    Reply = inputdlg('How Many Tracks Files Would You Like to Select?', ...
        'Plot Average Speed Histogram for Multiple Experiments', 1, {''}, 'on');
    NumReps = str2num(Reply{1});
else
    NumReps = 1;
end

if exist(Prefs.DefaultPath, 'dir') 
    cd(Prefs.DefaultPath);
end

for i = 1:NumReps
    if strcmp(Mode, 'Multiple')
        [FileName, PathName] = uigetfile('*.mat', 'Open Track File');
        cd(PathName);
        load([PathName,FileName]);
    end

    for TN = 1:length(Tracks)

        Tracks(TN).SmoothX = RecSlidingWindow(Tracks(TN).Path(:,1)', Prefs.SmoothWinSize);
        Tracks(TN).SmoothY = RecSlidingWindow(Tracks(TN).Path(:,2)', Prefs.SmoothWinSize);

        % Calculate Speed
        Xdif = CalcDif(Tracks(TN).SmoothX, Prefs.StepSize) * Prefs.SampleRate;
        Ydif = -CalcDif(Tracks(TN).SmoothY, Prefs.StepSize) * Prefs.SampleRate;
        % Negative sign allows "correct" direction calcuation (i.e. 0 = Up/North)
        Tracks(TN).Speed = sqrt(Xdif.^2 + Ydif.^2) * Prefs.PixelSize;		% In mm/sec
    end

    allpointsout = [Tracks.Speed]';
    NumPts(i) = length(allpointsout);

    [n(i,:),x] = hist([Tracks.Speed], Bins);
    n(i,:) = n(i,:)/NumPts(i);
end

Tracks = SaveTracks;  % Clean up...       


if NumReps > 1
    nMean = mean(n);
    nSEM = std(n)/sqrt(NumReps);
else
    nMean = n;
end
    
MeanSpeed = sum(nMean.*Bins);
disp(['Average speed = ' num2str(MeanSpeed) ' mm/s']);


% Calc cdf
for i = 1:length(nMean)
    cdf(i) = sum(nMean(1:i));
end
figure
plot(x,cdf,'bo-')
set(gca, 'FontName', 'Arial', 'FontSize', 14, 'Box', 'off');
title('Worm Speed Cumulative Probability Distribution')
xlabel('Worm Speed (mm/sec)')
ylabel('Cumulative Probability')

% Plot histogram
figure
hold on
if NumReps > 1
    errorbar(x,nMean,zeros(1,length(Bins)),nSEM,'k.')
end
bar(x,nMean)
set(gca, 'FontName', 'Arial', 'FontSize', 14, 'Box', 'off');
title('Worm Speed Histogram')
xlabel('Worm Speed (mm/sec)')
ylabel('Probability')



