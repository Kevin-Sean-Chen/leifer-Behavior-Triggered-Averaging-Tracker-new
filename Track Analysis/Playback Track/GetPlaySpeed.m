function PlaySpeed = GetPlaySpeed(PlayState)

global Prefs;

switch PlayState
    case 'PLAY'
        PlaySpeed = 1;
    case 'FF'
        PlaySpeed = Prefs.FFSpeed;
    case 'BACK'
        PlaySpeed = -1;
    case 'RW'
        PlaySpeed = (-1 * Prefs.FFSpeed);
    otherwise
        PlaySpeed = 0;
end