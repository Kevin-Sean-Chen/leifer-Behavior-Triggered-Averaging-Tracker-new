function VidGrabFramesToAVI()

global vid
global aviobj
global CaptureTime
global VideoPrefs
persistent LastFrameTime

T = timerfind('Tag', 'CaptureTimer');
FramesCaptured = get(T, 'UserData');
nFrames = vid.FramesPerTrigger;

MainT = timerfind('Tag', 'MainTimer');
n = get(MainT, 'TasksExecuted');

availFrames = vid.FramesAvailable;
if availFrames > 0
    % get the image from the camera
    [data, time, metadata] = getdata(vid, availFrames, 'uint8');

    if FramesCaptured == 0
        CaptureTime(n,:) = metadata(1).AbsTime;
        disp(['First Frame Time: ' num2str(metadata(1).AbsTime(5)), 'min ' ...
            num2str(metadata(1).AbsTime(6)) 'sec']);
        LastFrameTime = metadata(1).AbsTime(6) - 1/7.5; 
            % Avoid frame interval check failure on first frame
    end
        
    % check frame interval...
    FrameIntervals = [metadata(1).AbsTime(6) - LastFrameTime; diff(time)];
    if max(FrameIntervals) > 1.1*(1/VideoPrefs.SampleRate) || ...
            min(FrameIntervals) < 0.9*(1/VideoPrefs.SampleRate)
        disp('Suspicious intervals between frames!');
        disp(['Starting at Frame #' num2str(FramesCaptured+1)]);
        disp(num2str(FrameIntervals));
    end

    for i=1:availFrames
        % create down-sampled image, add to avi file...
        im = imresize(data(:,:,:,i), [480 640], 'nearest');
        % something to output 'im' to a picture file
        
        aviobj = addframe(aviobj, im2frame(im, colormap(gray(256))));
    end
    clear data;
    
    FramesCaptured = FramesCaptured + availFrames;    
    set(T, 'UserData', FramesCaptured);
    LastFrameTime = metadata(availFrames).AbsTime(6); 

    if FramesCaptured == nFrames
        disp(['Last Frame Time: ' num2str(metadata(availFrames).AbsTime(5)), 'min ' ...
            num2str(metadata(availFrames).AbsTime(6)) 'sec']);
    end
    
end



