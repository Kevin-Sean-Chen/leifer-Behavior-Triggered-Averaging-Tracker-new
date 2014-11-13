function StartVidCapture(hObject, eventdata, handles)

global vid
global CaptureTime
global VideoPrefs

CaptureTime = [];
MaxFileSize = 6300;     % Max file size supported by Matlab (in frames)
                               

if strcmp(get(hObject, 'String'), 'Stop Capture')    % Capture already RUNNING -> STOP it %
                                                     % ---------------------------------- %
    if isrunning(vid)                       % If video object is running
        stop(vid);                          % Stop video capture
    end

    MainT = timerfind('Tag', 'MainTimer');
    delete(MainT);
    clear MainT

    % Update interface
    set(findobj('Tag', 'StartCapture'), 'String', 'Start Capture');

else            % Capture is STOPPED -> START it %
                % ------------------------------ %

    % Check Capture Parameters - num frames per capture & movie name
    nFrames = round(str2num(get(findobj('Tag', 'CaptureTime'), 'String'))*VideoPrefs.SampleRate);
    if nFrames > MaxFileSize
        DLG = errordlg('Too many frames per capture (max 6300)','Capture Settings Error');
        set(DLG, 'WindowStyle', 'modal');
        return
    end

    % Set number of frames to capture
    nFrames = round(str2num(get(findobj('Tag', 'CaptureTime'), 'String'))*VideoPrefs.SampleRate);
    set(vid, 'FramesPerTrigger', nFrames);

    savePath = get(findobj('Tag', 'savePath'),'String');
    saveName = get(findobj('Tag', 'saveName'),'String');
    saveName = [saveName(1:length(saveName)-4), '1.avi'];
    MovieName = strcat(savePath, saveName);
    if exist(MovieName, 'file')
        Warning = ['You are about to overwrite movie: ' saveName];
        Response = questdlg(Warning, 'Warning! Movie already exists', ...
            'Continue', 'Cancel','Continue');
        if strcmp(Response, 'Continue')
            delete(MovieName);
        else
            return
        end
    end

    % Update interface
    set(hObject, 'String', 'Stop Capture');

    % Set Main Capture Loop Timer
    ExpDur = str2num(get(findobj('Tag', 'ExperimentDuration'), 'String'))*60;
    Period = str2num(get(findobj('Tag', 'CaptureEvery'), 'String'))*60;
    numCaptures = round(ExpDur/Period);

    MainT = timer('Tag', 'MainTimer',...
        'ExecutionMode', 'fixedRate',...
        'Period', Period,...
        'TasksToExecute', numCaptures,...
        'TimerFcn', 'VidCaptureTimerFcn', ...
        'UserData', {MovieName, hObject, get(findobj('Tag', 'RTAnalyzeOn'),'Value')});

    start(MainT);

end

    
