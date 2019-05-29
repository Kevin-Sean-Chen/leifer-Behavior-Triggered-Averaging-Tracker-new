% This script performs behavioral analysis without a cluster

% analysis options
tracking = 1;
finding_centerline = 0;
resolving_problems = 0;
plotting = 0;
calculate_behavior = 0;
parameters = load_parameters(); %load default parameters


%% STEP 1: Get folders
[folders, folder_count] = getfolders();

%% STEP 3: Track and save the individual worm images %%
tic
if tracking
    'Tracking...'
   
    if folder_count > 1
        %use parfor
        parfor folder_index = 1:folder_count
%         for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            track_image_directory(folder_name, 'all');
        end
    else
        for folder_index = 1:folder_count
            folder_name = folders{folder_index};
            track_image_directory(folder_name, 'all');
        end
    end
end
toc
%% STEP 4: Find centerlines %%
if finding_centerline
    'Getting Centerlines...'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        find_centerlines(folder_name);
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


%% STEP 7: do behavioral mapping
if calculate_behavior
   'Getting Behaviors'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        calculate_spectra(folder_name);
        calculate_embeddings(folder_name);
        calculate_behaviors(folder_name);
    end
end

%% STEP 8: Plot
if plotting
    'Plotting...'
    for folder_index = 1:folder_count
        folder_name = folders{folder_index}
        plot_image_directory(folder_name);
    end 
end
