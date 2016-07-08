function [ Prefs ] = load_excel_prefs()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    SaveIndividualImages = 1;

    Prefs = load('EigenVectors.mat'); %load eigenvectors for eigenworms
    Prefs.SaveIndividualImages = SaveIndividualImages;
    [~, ComputerName] = system('hostname'); %get the computer name

    %Get Tracker default Prefs from Excel file
    ExcelFileName = 'Worm Tracker Preferences';
    WorkSheet = 'Tracker Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    for computer_index = 1:size(T,2)
        if strcmp(T{1,computer_index}, strtrim(ComputerName))
            break
        end
    end
    computer_index = computer_index - 1; % the first column does not count
    Prefs.MinWormArea = N(1,computer_index);
    Prefs.MaxWormArea = N(2,computer_index);
    Prefs.MaxDistance = N(3,computer_index);
    Prefs.SizeChangeThreshold = N(4,computer_index);
    Prefs.MinTrackLength = N(5,computer_index);
    Prefs.AutoThreshold = N(6,computer_index);
    Prefs.CorrectFactor = N(7,computer_index);
    Prefs.ManualSetLevel = N(8,computer_index);
    Prefs.DarkObjects = N(9,computer_index);
    Prefs.PlotRGB = N(10,computer_index);
    Prefs.PauseDuringPlot = N(11,computer_index);
    Prefs.PlotObjectSizeHistogram = N(12,computer_index);
    if exist(T{14,computer_index+1}, 'file')
       %get the mask
       Prefs.Mask = imread(T{14,computer_index+1}); 
    else
       Prefs.Mask = 0;
    end
    Prefs.MaxObjects = N(14,computer_index);
    Prefs.PlottingFrameRate = N(15,computer_index);
    Prefs.IndividualVideoPlottingFrameRate = N(16,computer_index);
    if exist(T{18,computer_index+1}, 'file')
       %get the power distribution
       load(T{18,computer_index+1});
       Prefs.power500 = power500; 
    else
       Prefs.power500 = 0;
    end
    
    
    WorkSheet = 'Analysis Prefs';
    [N, T, D] = xlsread(ExcelFileName, WorkSheet);
    for computer_index = 1:size(T,2)
        if strcmp(T{1,computer_index}, strtrim(ComputerName))
            break
        end
    end
    computer_index = computer_index - 1; % the first column does not count
    Prefs.SampleRate = N(1,computer_index);
    Prefs.SmoothWinSize = N(2,computer_index);
    Prefs.StepSize = N(3,computer_index);
    Prefs.PlotDirection = N(4,computer_index);
    Prefs.PlotSpeed = N(5,computer_index);
    Prefs.PlotAngSpeed = N(6,computer_index);
    Prefs.PirThresh = N(7,computer_index);
    Prefs.MaxShortRun = N(8,computer_index);
    Prefs.FFSpeed = N(9,computer_index);
    Prefs.PixelSize = 1/N(10,computer_index);
    Prefs.BinSpacing = N(11,computer_index);
    Prefs.MaxSpeedBin = N(12,computer_index);
    Prefs.P_MaxSpeed = N(13,computer_index);
    Prefs.P_TrackFraction = N(14,computer_index);
    Prefs.P_WriteExcel = N(15,computer_index);
    Prefs.MinDisplacement = N(17,computer_index);
    Prefs.PirSpeedThresh = N(18,computer_index);
    Prefs.EccentricityThresh = N(19,computer_index);
    Prefs.PauseSpeedThresh = N(20,computer_index);
    Prefs.MinPauseDuration = N(21,computer_index);   
    Prefs.MaxBackwardsFrames = N(22,computer_index) * Prefs.SampleRate;
    Prefs.DefaultPath = T{17,computer_index+1};
    Prefs.ImageSize = [N(23,computer_index), N(23,computer_index)];   
    Prefs.MinAverageWormArea = N(24,computer_index);
    Prefs.ProgressDir = pwd;

end

