[folders, folder_count] = getfolders();

Prefs = load_excel_prefs();


for folder_index = 1:length(folders)
    %single experiment
    folder_name = folders{folder_index};
    cd(folder_name) %open the directory of image sequence
    load('tracks.mat')

    Tracks = LEDVoltage2Power(Tracks,power500);
    
    save([folder_name '\tracks.mat'], 'Tracks');
    AutoSave(folder_name, Prefs.DefaultPath);

end
