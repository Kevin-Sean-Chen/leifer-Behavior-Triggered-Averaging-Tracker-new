function TrackAnalysis()% This function extracts the major parameters for the current Track and plots them% based on the preferences in Prefsglobal Tracks;global Prefs;global Current;% Get current track no.H = findobj('tag', 'SLIDER');TN = round(get(H, 'Value'));% Calculate track parameters% --------------------------if ~(Current.Analyzed)	Tracks(TN).Time = Tracks(TN).Frames/Prefs.SampleRate;		% Calculate time of each frame	Tracks(TN).NumFrames = length(Tracks(TN).Frames);		    % Number of frames	% Smooth track data by rectangular sliding window of size WinSize;	Tracks(TN).SmoothX = RecSlidingWindow(Tracks(TN).Path(:,1)', Prefs.SmoothWinSize);	Tracks(TN).SmoothY = RecSlidingWindow(Tracks(TN).Path(:,2)', Prefs.SmoothWinSize);	% Calculate Direction & Speed	Xdif = CalcDif(Tracks(TN).SmoothX, Prefs.StepSize) * Prefs.SampleRate;	Ydif = -CalcDif(Tracks(TN).SmoothY, Prefs.StepSize) * Prefs.SampleRate;    % Negative sign allows "correct" direction                                                                               % cacluation (i.e. 0 = Up/North)	ZeroYdifIndexes = find(Ydif == 0);    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation    	Tracks(TN).Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")    NegYdifIndexes = find(Ydif < 0);    Index1 = find(Tracks(TN).Direction(NegYdifIndexes) <= 0);	Index2 = find(Tracks(TN).Direction(NegYdifIndexes) > 0);	Tracks(TN).Direction(NegYdifIndexes(Index1)) = Tracks(TN).Direction(NegYdifIndexes(Index1)) + 180;	Tracks(TN).Direction(NegYdifIndexes(Index2)) = Tracks(TN).Direction(NegYdifIndexes(Index2)) - 180;	Tracks(TN).Speed = sqrt(Xdif.^2 + Ydif.^2) * Prefs.PixelSize;		% In mm/sec	% Calculate angular speed	Tracks(TN).AngSpeed = CalcAngleDif(Tracks(TN).Direction, Prefs.StepSize) * Prefs.SampleRate;		% in deg/sec        % Identify Pirouettes (Store as indices in Tracks(TN).Pirouettes)    Tracks(TN).Pirouettes = IdentifyPirouettes(Tracks(TN));    Current.Analyzed = 1;end% Replot smooth track & analysis results % --------------------------------------if ~Current.BatchAnalysis    % Don't plot results if running in Batch Mode        figure(Prefs.FigH);    hold on;    p = size(Tracks(TN).Pirouettes);    for n = 1:p(1)        PIndex = [Tracks(TN).Pirouettes(n,1):Tracks(TN).Pirouettes(n,2)];        plot(Tracks(TN).SmoothX(PIndex), Tracks(TN).SmoothY(PIndex), 'g');    end      hold off;            AnalFigH = findobj('Tag', 'ANALFIG');    if isempty(AnalFigH)        AnalFigH = figure('Name', 'Analysis Results', 'NumberTitle', 'off', ...            'Tag', 'ANALFIG');    else        figure(AnalFigH)    end        NumPlots = Prefs.PlotDirection + Prefs.PlotSpeed + Prefs.PlotAngSpeed;    i = 1;    if Prefs.PlotDirection        SubP = [NumPlots,1,i];        Plotter(Tracks(TN).Time, Tracks(TN).Direction, AnalFigH, SubP, 'b', 'Worm instantaneous direction', ...             '', 'Direction (deg)', 'on', 'on', 'off');        ax = get(gcf,'CurrentAxes');        set(ax, 'YLim', [-180, 180]);        if i ~= NumPlots            set(ax, 'XTickLabel', '');        else            xlabel('Time (sec)');        end        i = i+1;    end        if Prefs.PlotSpeed        SubP = [NumPlots,1,i];        Plotter(Tracks(TN).Time, Tracks(TN).Speed, AnalFigH, SubP, 'r', 'Worm instantaneous speed', ...             '', 'Speed (mm/sec)', 'on', 'on', 'off');        if i ~= NumPlots            ax = get(gcf,'CurrentAxes');            %set(ax, 'XTickLabel', '');        else            xlabel('Time (sec)');        end        i = i+1;    end        if Prefs.PlotAngSpeed        SubP = [NumPlots,1,i];        Plotter(Tracks(TN).Time, Tracks(TN).AngSpeed, AnalFigH, SubP, 'r', 'Worm instantaneous angular speed', ...             '', 'Angular Velocity (deg/sec)', 'on', 'on', 'off');        hold on;        p = size(Tracks(TN).Pirouettes);        for n = 1:p(1)            PIndex = [Tracks(TN).Pirouettes(n,1):Tracks(TN).Pirouettes(n,2)];            Plotter(Tracks(TN).Time(PIndex), Tracks(TN).AngSpeed(PIndex), AnalFigH, SubP, 'g');            zoom on;        end          hold off;        if i ~= NumPlots            ax = get(gcf,'CurrentAxes');            set(ax, 'XTickLabel', '');        else            xlabel('Time (sec)');        end        i = i+1;    end    end    % END IF ~Current.BatchAnalysis