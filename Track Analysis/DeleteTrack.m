function DeleteTrack()

global Tracks;

button = questdlg('Delete Current Track?','Delete Track','OK','Cancel','OK');

if strcmp(button,'OK')
    % Get current track no.
    H = findobj('tag', 'SLIDER');
    TN = round(get(H, 'Value'));
    
    Tracks(TN) = [];
    
    NumTracks = length(Tracks);
    H = findobj('tag', 'SLIDER');
    set(H, 'Value', TN, ...
        'SliderStep', [1,10]/NumTracks, ...
        'Max', NumTracks, ...
        'Min', 1);
    SelectTrack;  
end
