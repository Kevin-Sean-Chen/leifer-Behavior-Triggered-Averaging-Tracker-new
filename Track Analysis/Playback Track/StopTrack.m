function StopTrack()

global Current;

H = findobj('tag', 'STOP');
set(H, 'enable', 'off');

ActiveTag = GetActiveTag;

H = findobj('tag', ActiveTag);
set(H, 'enable', 'on');

Current.PlayState = 0;
