function Tracks = JoinTracks

MinDistance = 5;      % Min Distance for connecting a new worm to an existing track (in pixels)

% Track file names
Track1File = 'C:\Ce Behavioral Analysis\N2 Data\Experiment1\Tracks Part1.mat';
Track2File = 'C:\Ce Behavioral Analysis\N2 Data\Experiment1\Tracks Part2.mat';

% Movie for First Track File
MovieFile = 'C:\Ce Behavioral Analysis\N2 Data\Experiment1\Movie Part1.avi';
FileInfo = aviinfo(MovieFile);

% Load Tracks
load(Track1File);
Tracks1 = Tracks;
load(Track2File);
Tracks2 = Tracks;

clear Tracks;

% Join Tracks
% -----------

% Find Tracks in first Tracks file that are still active
if ~isempty(Tracks1)
    ActiveTracks = find([Tracks1.Active]);
else
    ActiveTracks = [];
end

% Shift Tracks from 2nd Tracks file by [length of 1st movie] frames,  
% And find Tracks in 2nd Tracks file that start at the beginning of the 2nd movie
Indices = [];
for i = 1:length(Tracks2)
    Tracks2(i).Frames = Tracks2(i).Frames + FileInfo.NumFrames;
    if Tracks2(i).Frames(1) == FileInfo.NumFrames + 1
        Indices = [Indices, i];
    end
end

for i = 1:length(ActiveTracks)
    for j = 1:length(Indices)
        DistanceX(j) = Tracks1(ActiveTracks(i)).LastCoordinates(1) - Tracks2(Indices(j)).Path(1,1);
        DistanceY(j) = Tracks1(ActiveTracks(i)).LastCoordinates(2) - Tracks2(Indices(j)).Path(1,2);
    end
    Distance = sqrt(DistanceX.^2 + DistanceY.^2);
    [MinVal, MinIndex] = min(Distance);
    if MinVal <= MinDistance
        Tracks1(ActiveTracks(i)).Path = [Tracks1(ActiveTracks(i)).Path; Tracks2(Indices(MinIndex)).Path];
        Tracks1(ActiveTracks(i)).LastCoordinates = Tracks2(Indices(MinIndex)).LastCoordinates;
        Tracks1(ActiveTracks(i)).Frames = [Tracks1(ActiveTracks(i)).Frames, Tracks2(Indices(MinIndex)).Frames];
        Tracks1(ActiveTracks(i)).Size = [Tracks1(ActiveTracks(i)).Size, Tracks2(Indices(MinIndex)).Size];
        Tracks1(ActiveTracks(i)).LastSize = Tracks2(Indices(MinIndex)).LastSize;
        Tracks1(ActiveTracks(i)).FilledArea = [Tracks1(ActiveTracks(i)).FilledArea, Tracks2(Indices(MinIndex)).FilledArea];
        Tracks1(ActiveTracks(i)).Eccentricity = [Tracks1(ActiveTracks(i)).Eccentricity, Tracks2(Indices(MinIndex)).Eccentricity];
        Tracks1(ActiveTracks(i)).Active = Tracks2(Indices(MinIndex)).Active;
        Tracks2(Indices(MinIndex)) = [];
    else
        Tracks1(ActiveTracks(i)).Active = 0;
    end
end

Tracks = [Tracks1, Tracks2];

[FileName,PathName] = uiputfile('*.mat', 'Save Track Data');
if FileName ~= 0
    save([PathName, FileName], 'Tracks');
end
