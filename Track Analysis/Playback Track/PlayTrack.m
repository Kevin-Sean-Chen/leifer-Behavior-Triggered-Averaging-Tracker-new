function PlayTrack(PlayState)

global Tracks;
global Prefs;
global Current;

% Get current track no. and play state
H = findobj('tag', 'SLIDER');
TN = round(get(H, 'Value'));
PlaySpeed = GetPlaySpeed(PlayState);

H = findobj('tag', PlayState);
set(H, 'enable', 'off');

ActiveTag = GetActiveTag;
H = findobj('tag', ActiveTag);
set(H, 'enable', 'on');

Current.PlayState = PlaySpeed;
FirstFrame = Current.PlayFrame;
MaxFrame = length(Tracks(TN).Frames);
tic;

if Current.Analyzed
    while Current.PlayState == PlaySpeed
        if Current.PlayState > 0 & Current.PlayFrame >= MaxFrame
            break
        else if Current.PlayState < 0 & Current.PlayFrame <= 1
                break
            end
        end
        if gcf ~= Prefs.FigH;
            figure(Prefs.FigH);
        end
        Current.PlayFrame = max(min(round(FirstFrame + (toc * Prefs.SampleRate * Current.PlayState)), MaxFrame), 1);
        if Tracks(TN).Frames(Current.PlayFrame) <= Prefs.FirstMovieLen
            Mov = aviread(Prefs.MovieName(1,:), Tracks(TN).Frames(Current.PlayFrame));
        else
            Mov = aviread(Prefs.MovieName(2,:), Tracks(TN).Frames(Current.PlayFrame)-Prefs.FirstMovieLen);
        end
        imshow(Mov.cdata, Mov.colormap);
        hold on;
        plot(Tracks(TN).SmoothX, Tracks(TN).SmoothY,  'r');
        p = size(Tracks(TN).Pirouettes);
        for n = 1:p(1)
            PIndex = [Tracks(TN).Pirouettes(n,1):Tracks(TN).Pirouettes(n,2)];
            plot(Tracks(TN).SmoothX(PIndex), Tracks(TN).SmoothY(PIndex), 'g');
        end  
        plot(Tracks(TN).SmoothX(Current.PlayFrame), Tracks(TN).SmoothY(Current.PlayFrame), 'b+');
        hold off;
        H = findobj('tag', 'FRAMENUM');
        set(H, 'String', num2str(Tracks(TN).Frames(Current.PlayFrame)));
        H = findobj('tag', 'TIMEELAPSED');
        set(H, 'String', num2str(round(Tracks(TN).Frames(Current.PlayFrame)/Prefs.SampleRate)));
        pause(1/(Prefs.SampleRate*1));
    end
else
    while Current.PlayState == PlaySpeed
        if Current.PlayState > 0 & Current.PlayFrame >= MaxFrame
            break
        else if Current.PlayState < 0 & Current.PlayFrame <= 1
                break
            end
        end
        if gcf ~= Prefs.FigH;
            figure(Prefs.FigH);
        end
        Current.PlayFrame = max(min(round(FirstFrame + (toc * Prefs.SampleRate * Current.PlayState)), MaxFrame), 1);
        if Tracks(TN).Frames(Current.PlayFrame) <= Prefs.FirstMovieLen
            Mov = aviread(Prefs.MovieName(1,:), Tracks(TN).Frames(Current.PlayFrame));
        else
            Mov = aviread(Prefs.MovieName(2,:), Tracks(TN).Frames(Current.PlayFrame)-Prefs.FirstMovieLen);
        end
        imshow(Mov.cdata, Mov.colormap);
        hold on;
        plot(Tracks(TN).Path(:,1), Tracks(TN).Path(:,2),  'r');
        plot(Tracks(TN).Path(Current.PlayFrame,1), Tracks(TN).Path(Current.PlayFrame,2), 'b+');
        hold off;
        H = findobj('tag', 'FRAMENUM');
        set(H, 'String', num2str(Tracks(TN).Frames(Current.PlayFrame)));
        H = findobj('tag', 'TIMEELAPSED');
        set(H, 'String', num2str(round(Tracks(TN).Frames(Current.PlayFrame)/Prefs.SampleRate)));
        pause(1/(Prefs.SampleRate*1));
    end
end

if (Current.PlayState > 0 & Current.PlayFrame == MaxFrame) | (Current.PlayState < 0 & Current.PlayFrame == 1)
    Current.PlayState = 0;

    H = findobj('tag', 'STOP');
    set(H, 'enable', 'off');

    H = findobj('tag', PlayState);
    set(H, 'enable', 'on');
end   


