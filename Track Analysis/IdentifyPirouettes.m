function Pirouettes = IdentifyPirouettes(Track)

% This function receives a structure Track and automatically identifies pirouettes  
% in the track data. The results of this analysis are stored in the struct Track
% (in the field track.Pirouettes) and returned to the calling function.

% Identified pirouettes are stored in Track as two columns of indices - the first
% indicating pirouette start indices, the second indicating corresponding
% pirouette end indices. 

global Prefs;

% Calculate Angular velocity pirouette threshold
% ----------------------------------------------
Esqr = mean((Track.AngSpeed).^2);
% E = mean(abs(Track.AngSpeed));
AverageAngSpeed = sqrt(Esqr);
% PirThreshMult = 1.5;
% AngSpeedSTD = sqrt(Esqr - E^2);
% PirThresh = max(AverageAngSpeed * PirThreshMult, Prefs.PirThresh);
PirThresh = Prefs.PirThresh;

% Find Pirouettes
% ---------------
PirI = find(abs(Track.AngSpeed) > PirThresh);
PirI = PirI(find(PirI > 8 & PirI < length(Track.Frames) - 8));            % Disregard first and last second of movie
if isempty(PirI)
    Pirouettes = [];
else
    PirEndI = find(diff(PirI) > Prefs.MaxShortRun*Prefs.SampleRate);
    if isempty(PirEndI)
        Pirouettes = [PirI(1), PirI(length(PirI))];
    else
        Pirouettes = [PirI(1), PirI(PirEndI(1))];
        for j = 1:length(PirEndI)-1
            Pirouettes = [Pirouettes; PirI(PirEndI(j)+1), PirI(PirEndI(j+1))];
        end
        Pirouettes = [Pirouettes; PirI(PirEndI(length(PirEndI))+1), PirI(length(PirI))];
    end
    if Track.NumFrames - PirI(length(PirI)) < Prefs.MaxShortRun*Prefs.SampleRate
        Pirouettes(length(Pirouettes(:,2)), 2) = Track.NumFrames;
    end
end
% x = Track.Frames(Pirouettes)
    