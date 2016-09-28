folders = getfolders();

[ allTracks, folder_indecies, ~ ] = loadtracks(folders);

[LNPStats, meanLEDPower, stdLEDPower] = FitLNP(allTracks,folder_indecies,folders);
PlotBehavioralMappingExperimentGroup(LNPStats, meanLEDPower, stdLEDPower);
