% find min and max phi_dt for a dataset

folders = getfolders();

%% STEP 2: Load the analysis preferences from Excel %%
if ~exist('Prefs', 'var')
    Prefs = load_excel_prefs();
end

%% STEP 3: load the tracks into memory
[allTracks, ~, ~] = loadtracks(folders);
L = length(allTracks);

all_phi_dt = [];

for track_index = 1:L
    phi_dt = worm_phase_velocity(allTracks(track_index).ProjectedEigenValues, Prefs);
    all_phi_dt = [all_phi_dt, phi_dt];
end

min_phi_dt = min(all_phi_dt)
max_phi_dt = max(all_phi_dt)