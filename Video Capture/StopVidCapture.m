function StopVidCapture()

% This function executes upon a stop event (either due to a stop command or
% when the number of frames specified for the trigger has been acquired)

global vid
global aviobj


% Wrap Up Video Acquisition
% -------------------------
VidGrabFramesToAVI;    % Get last frames...

T = timerfind('Tag', 'CaptureTimer');

FramesCaptured = get(T, 'UserData');
nFrames = vid.FramesPerTrigger;

stop(T);
delete(T);

aviobj = close(aviobj);
disp(['FramesAcquired = ', num2str(vid.FramesAcquired)]);
% events = vid.EventLog;

MainT = timerfind('Tag', 'MainTimer');
n = get(MainT, 'TasksExecuted');

if FramesCaptured == nFrames
    UD = get(MainT, 'UserData');
    MovieName = [UD{1}(1:length(UD{1})-5), num2str(n), '.avi'];
    if UD{3}        % If "Analyze during capture" option selected
        ParalysisTracker(MovieName);
    end
end

if get(MainT, 'TasksExecuted') == get(MainT, 'TasksToExecute')
    % Update interface
    UD = get(MainT, 'UserData');
    set(UD{2}, 'String', 'Start Capture');

    delete(MainT);
    clear MainT
end


