function IdentifyParalyzed(Mode)

global Prefs
global Tracks;

SaveTracks = Tracks;  % Store Tracks Data for current movie...       

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

% Setup display to report results....
disp(' ')
disp(' ')
disp(sprintf('File Name\t\t\tFraction Paralyzed\t\tTotal # Tracks\t\t# Paralyzed Tracks\t\tMean Speed (mm/s)\t\t# Speed Measurements'))
disp('-----------------------------------------------------------------------------------------------------------------------------------')

% Setup file for saving data (only on first run)
if Prefs.P_WriteExcel
    SaveFileName = [Prefs.DefaultPath 'Analysis Results.xls'];
    if ~exist(SaveFileName, 'file')
        xlswrite(SaveFileName, {'File Name','Fraction Paralyzed','Total # Tracks', ...
            '# Paralyzed Tracks','Mean Speed (mm/s)','# Speed Measurements'});
    end
end

for i = 1:NumReps
    if strcmp(Mode, 'Multiple')
        [FileName, PathName] = uigetfile('*.mat', 'Open Track File');
        cd(PathName);
        load([PathName,FileName]);
    else
        FileName = 'Current Movie';
    end

    P_Total = 0;
    P_NumTracks = 0;

    for TN = 1:length(Tracks)

        Tracks(TN).SmoothX = RecSlidingWindow(Tracks(TN).Path(:,1)', Prefs.SmoothWinSize);
        Tracks(TN).SmoothY = RecSlidingWindow(Tracks(TN).Path(:,2)', Prefs.SmoothWinSize);

        % Calculate Speed
        Xdif = CalcDif(Tracks(TN).SmoothX, Prefs.StepSize) * Prefs.SampleRate;
        Ydif = -CalcDif(Tracks(TN).SmoothY, Prefs.StepSize) * Prefs.SampleRate;
        % Negative sign allows "correct" direction calcuation (i.e. 0 = Up/North)
        Tracks(TN).Speed = sqrt(Xdif.^2 + Ydif.^2) * Prefs.PixelSize;		% In mm/sec
        if sum(Tracks(TN).Speed < Prefs.P_MaxSpeed)/length(Tracks(TN).Speed) > Prefs.P_TrackFraction
            P_Total = P_Total + length(Tracks(TN).Speed);
            P_NumTracks = P_NumTracks + 1;
        end
    end

    allpointsout = [Tracks.Speed]';
    MeanSpeed = mean(allpointsout);
    NumPts = length(allpointsout);
    FractionParalyzed = P_Total/length([Tracks.Frames]);
    NumTracks = length(Tracks);

    Spacer = '';
    for j = 1:26-length(FileName)
        Spacer = [Spacer, ' '];
    end
    disp(sprintf('%s%s%1.3f\t\t\t\t\t%4.0f\t\t\t\t%4.0f\t\t\t\t\t\t%1.3f\t\t\t%15.0f', ...
        FileName, Spacer, FractionParalyzed, NumTracks, P_NumTracks, MeanSpeed, NumPts))
    disp('')
    
    if Prefs.P_WriteExcel
        [num, txt, raw]= xlsread(SaveFileName);
        xlswrite(SaveFileName, {FileName, FractionParalyzed, NumTracks, ...
            P_NumTracks, MeanSpeed, NumPts}, 1, ['A' num2str(size(raw, 1)+1)]);
    end

end

Tracks = SaveTracks;    % Clean up...     

