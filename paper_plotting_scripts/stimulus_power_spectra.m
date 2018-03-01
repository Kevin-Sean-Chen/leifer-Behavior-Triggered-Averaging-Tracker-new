fps = 14;

[FileName,PathName,~] = uigetfile;
voltages = load([PathName,filesep,FileName]);
figure
periodogram(voltages,rectwin(length(voltages)),length(voltages),fps, 'power')
figure
autocorr(voltages)
xlabel('frames (at 14fps)')