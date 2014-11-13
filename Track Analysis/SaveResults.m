function SaveResults()

global Tracks;

[SaveFile, SavePath] = uiputfile('*.mat', 'Save Tracks Analysis Results');
FileName = [SavePath, SaveFile];

if SaveFile ~= 0
    save(FileName, 'Tracks');
end
