function SelectTrack

% This function loads the parameters of the track selected by the user
% (using the track slider) into struct Track and displays the selected
% track. 
% This function is the callback for the slider object with tag SLIDER

global Tracks;
global Prefs;
global Current;

% Get and display the selected track no.
H = findobj('tag', 'SLIDER');
TN = round(get(H, 'Value'));

H = findobj('tag', 'SLIDERTITLE');
String = ['Track No.', num2str(TN)];
set(H, 'string', String);

% Initialize Current Track State
Current.Analyzed = 0;
Current.TempAnalyzed = 0;
Current.PlayFrame = 1;
Current.PlayState = 0;
Current.BatchAnalysis = 0;

% Display selected track
hold off;
if Tracks(TN).Frames(1) <= Prefs.FirstMovieLen
    Mov = aviread(Prefs.MovieName(1,:), Tracks(TN).Frames(1));
else
    Mov = aviread(Prefs.MovieName(2,:), Tracks(TN).Frames(1)-Prefs.FirstMovieLen);
end
imshow(Mov.cdata, Mov.colormap);
hold on;
plot(Tracks(TN).Path(:,1), Tracks(TN).Path(:,2),  'r');
plot(Tracks(TN).Path(1,1), Tracks(TN).Path(1,2),  'b+');

% Update frame number & elapsed time
H = findobj('tag', 'FRAMENUM');
set(H, 'String', num2str(Tracks(TN).Frames(1)));
H = findobj('tag', 'TIMEELAPSED');
set(H, 'String', num2str(round(Tracks(TN).Frames(1)/Prefs.SampleRate)));



