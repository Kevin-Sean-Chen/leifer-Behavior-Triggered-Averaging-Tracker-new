% analysis options
tracking = 0;
finding_centerline = 1;
resolving_problems = 1;
plotting = 1;
SaveIndividualImages = 1;
backup = 0;


%% STEP 1: Get folders
[folders, folder_count] = getfolders();

%% STEP 2: Load the analysis preferences from Excel %%
'Initializing...'
if ~exist('Prefs', 'var')
    Prefs = load_excel_prefs();
end

%% STEP 3: Track and save the individual worm images %%
if tracking
    'Tracking...'
    %Get a rough estimate of how much work needs to be done
    total_image_files = 0;
    for folder_index = 1:folder_count
        curDir = folders{folder_index};
        image_files = dir([curDir, '\*.tif']);
        total_image_files = total_image_files + length(image_files);
    end
    
    if folder_count > 1
        %use parfor
        poolobj = gcp('nocreate'); 
        if isempty(poolobj)
            parpool(min(7, folder_count))
        end
        parfor_progress(Prefs.ProgressDir, round(total_image_files/50));
        parfor folder_index = 1:folder_count
%         for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            TrackImageDirectory(folder_name, 'continue', Prefs);
        end
        parfor_progress(Prefs.ProgressDir, 0);
        poolobj = gcp('nocreate'); 
        delete(poolobj);
    else
        parfor_progress(Prefs.ProgressDir, round(total_image_files/50));
        for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            TrackImageDirectory(folder_name, 'analysis', Prefs);
        end
        parfor_progress(Prefs.ProgressDir, 0);
    end
end

%% STEP 4: Find centerlines %%
if finding_centerline
    'Getting Centerlines...'
%     poolobj = gcp('nocreate'); 
%     if isempty(poolobj)
%         parpool(7)
%     end
    for folder_index = 1:folder_count
        curDir = folders{folder_index}
        if exist([curDir, '\tracks.mat'], 'file') == 2
            load([curDir, '\tracks.mat'])
            if ~isfield(Tracks, 'Centerlines')
                %centerline not found
                Tracks = Find_Centerlines(Tracks, curDir, Prefs);
                saveFileName = [curDir '\tracks.mat'];
                save(saveFileName, 'Tracks', '-v7.3');
                AutoSave(curDir, Prefs.DefaultPath);
            end
        end
    end 
%     poolobj = gcp('nocreate'); 
%     delete(poolobj);
end

%% STEP 6: Resolve problems
if resolving_problems
    'Resolve Issues'
    for folder_index = 1:folder_count
        curDir = folders{folder_index}

        Tracks = auto_resolve_problems(curDir, Prefs);
        saveFileName = [curDir '\tracks.mat'];
        save(saveFileName, 'Tracks', '-v7.3');
        AutoSave(curDir, Prefs.DefaultPath);
    end 
end

%% STEP 7: Plot
if plotting
    'Plotting...'
    for folder_index = 1:folder_count
        curDir = folders{folder_index};
        PlotImageDirectory(curDir, Prefs);
    end 
end

%% STEP 8: copy the folder to back up
if backup
    'Backing Up Data'
    for folder_index = 1:folder_count
        curDir = folders{folder_index}
        
        AutoSave(curDir, Prefs.DefaultPath, true)
    end

end

%% STEP 9: get Spectra and behaviors
% CreateBehavioralMappingExperimentGroup(folders);
