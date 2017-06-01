fps = 14;
[FileName,PathName,~] = uigetfile;
voltages = load([PathName,filesep,FileName]);

periodogram(voltages,rectwin(length(voltages)),length(voltages),fps, 'power')