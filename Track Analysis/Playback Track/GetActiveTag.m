function ActiveTag = GetActiveTag()

global Current;
global Prefs;

switch Current.PlayState
    case 1
        ActiveTag = 'PLAY';
    case Prefs.FFSpeed
        ActiveTag = 'FF';
    case -1
        ActiveTag = 'BACK';
    case (-1 * Prefs.FFSpeed)
        ActiveTag = 'RW';
    otherwise
        ActiveTag = 'STOP';
end