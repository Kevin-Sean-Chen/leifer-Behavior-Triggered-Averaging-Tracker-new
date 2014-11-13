function VidCaptureTimerFcn()

global vid
global aviobj
global VideoPrefs


% Define movie file for capture, and set video object to log to that file
MainT = timerfind('Tag', 'MainTimer');
n = get(MainT, 'TasksExecuted');
UD = get(MainT, 'UserData');
MovieName = [UD{1}(1:length(UD{1})-5), num2str(n), '.avi'];
if exist(MovieName, 'file')
    delete(MovieName);
end

aviobj = avifile(MovieName, 'fps', VideoPrefs.SampleRate, 'compression', 'none',...
    'colormap', gray(256));

% Start Capture
figure(1)   % Weird bug... For some reason, im2frame in VidGrabFramesToAVI opens a figure
            % this slows down execution leading to an unsolved timing bug
            % Preempting the figure here solves this bug... Ugly, but works.
start(vid);

% delete all existing CaptureTimers
delete(timerfind('Tag', 'CaptureTimer'));

% start timer for grabbing frames from memory and writing them to disk
FramesCaptured = 0;
GrabFramesPeriod = 2;       % in sec
T = timer('Tag', 'CaptureTimer',...
    'ExecutionMode', 'fixedRate',...
    'Period', GrabFramesPeriod,...
    'TasksToExecute', 1e10,...
    'TimerFcn', 'VidGrabFramesToAVI',...
    'UserData', FramesCaptured);
start(T);

 