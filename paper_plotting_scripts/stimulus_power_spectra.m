fps = 14;

[FileName,PathName,~] = uigetfile;
voltages = load([PathName,filesep,FileName]);
figure
periodogram(voltages,rectwin(length(voltages)),length(voltages),fps, 'power')
figure
autocorr(voltages)
xlabel('frames (at 14fps)')

%% get stimulus distribution for a group of experiments
allLEDPowers = [];
folders = getfoldersGUI;
for folder_index = 1:length(folders)
    parameters = load_parameters(folders{folder_index});
    LEDVoltages = load([folders{folder_index}, filesep, 'LEDVoltages.txt']);
    LEDPowers = LEDVoltages ./ 5 .* parameters.avgPower500;
    allLEDPowers = [allLEDPowers, LEDPowers];
end

h = histogram(allLEDPowers,linspace(0,51,9));
axis([0 50 0 500000])
set(gca,'XTick',[0 50])
set(gca,'YTick',linspace(0, 500000, 3))
xlabel('Power (uW mm^{-2})');
ylabel('Count (Frames)');