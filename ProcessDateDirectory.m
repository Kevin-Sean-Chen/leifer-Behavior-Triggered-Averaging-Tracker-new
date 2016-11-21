% analysis options
tracking = 0;
finding_centerline = 0;
resolving_problems = 1;
plotting = 0;
calculate_behavior = 0;
backup = 0;
parameters = load_parameters(); %load default parameters


%% STEP 1: Get folders
[folders, folder_count] = getfolders();

%% STEP 3: Track and save the individual worm images %%
if tracking
    'Tracking...'
    %Get a rough estimate of how much work needs to be done
    total_image_files = 0;
    for folder_index = 1:folder_count
        folder_name = folders{folder_index};
        image_files=dir([folder_name, filesep, '*.jpg']); %get all the jpg files (maybe named tif)
        if isempty(image_files)
            image_files = dir([folder_name, filesep, '*.tif']); 
        end
        total_image_files = total_image_files + length(image_files);
    end
    
    parfor_progress(parameters.ProgressDir, round(total_image_files/50));
    if folder_count > 1
        %use parfor
        parfor folder_index = 1:folder_count
%         for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            TrackImageDirectory(folder_name, 'continue');
        end
    else
        for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            TrackImageDirectory(folder_name, 'analysis');
        end
    end
    parfor_progress(parameters.ProgressDir, 0);
end

%% STEP 4: Find centerlines %%
if finding_centerline
    'Getting Centerlines...'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        Find_Centerlines(folder_name);
    end 
end

%% STEP 6: Resolve problems
if resolving_problems
    'Resolve Issues'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        auto_resolve_problems(folder_name);
    end 
end


%% STEP 7: get Spectra and behaviors
if calculate_behavior
   'Getting Behaviors'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        calculate_behaviors(folder_name);
    end
end

%% STEP 8: Plot
if plotting
    'Plotting...'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        PlotImageDirectory(folder_name);
    end 
end

%% STEP 9: copy the folder to back up
if backup
    'Backing Up Data'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        AutoSave(folder_name, true)
    end
end