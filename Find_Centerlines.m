function Tracks = Find_Centerlines(Tracks, image_files, medianProj, mask)
    global WormTrackerPrefs

    image_size = [50,50];
    frame_count = length(image_files)-1;
    tracks_start_in_frame = logical(sparse(length(Tracks), frame_count));
    tracks_end_in_frame = logical(sparse(length(Tracks), frame_count));
    for track_index = 1:length(Tracks)
        tracks_start_in_frame(track_index, Tracks(track_index).Frames(1)) = true;
        tracks_end_in_frame(track_index, Tracks(track_index).Frames(end)) = true;
    end
    
    saved_image_stacks = [];
    current_image_stacks = [];
    for frame_index = 1:length(image_files)-1
        tracks_that_start_in_this_frame = find(tracks_start_in_frame(:,frame_index));
        if ~isempty(tracks_that_start_in_this_frame)
            %%%there are tracks that start in this frame%%%
            for new_track_index = 1:length(tracks_that_start_in_this_frame)
                track_index = tracks_that_start_in_this_frame(new_track_index);
                current_image_stacks(length(current_image_stacks)+1).TrackIndex = track_index;
                current_image_stacks(length(current_image_stacks)).TrackStartFrame = frame_index;
                current_image_stacks(length(current_image_stacks)).Images = zeros([image_size, length(Tracks(track_index).Frames)]);
            end
        end
        
        %%%image processing%%%
        curImage = imread(image_files(frame_index).name);
        subtractedImage = curImage - uint8(medianProj) - mask; %subtract median projection  - imageBackground
        if WormTrackerPrefs.AutoThreshold       % use auto thresholding
            Level = graythresh(subtractedImage) + WormTrackerPrefs.CorrectFactor;
            Level = max(min(Level,1) ,0);
        else
            Level = WormTrackerPrefs.ManualSetLevel;
        end
        % Convert frame to a binary image 
        NUM = WormTrackerPrefs.MaxObjects + 1;
        while (NUM > WormTrackerPrefs.MaxObjects)
            if WormTrackerPrefs.DarkObjects
                BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
            else
                BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
            end
            % Identify all objects
            [L,NUM] = bwlabel(BW);
            Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
        end

            
        for image_stack_index = 1:length(current_image_stacks)
            track_index = current_image_stacks(image_stack_index).TrackIndex;
            in_track_index = frame_index - current_image_stacks(image_stack_index).TrackStartFrame + 1;

            region_index = Tracks(track_index).WormIndex(in_track_index);
            single_worm = L == region_index; %get an binary image of only where the worm is

            centroid_x = round(Tracks(track_index).Path(in_track_index,1));
            centroid_y = round(Tracks(track_index).Path(in_track_index,2));

            single_worm_subtractedImage = uint8(single_worm) .* subtractedImage; %get only the worm
            paddedSubtractedImage = padarray(single_worm_subtractedImage, image_size/2-1, 'both'); %pad the image so that there is no chance that the index is out of range
            worm_frame = paddedSubtractedImage(centroid_y:centroid_y+image_size(2)-1,centroid_x:centroid_x+image_size(1)-1);
            
%             imshow(worm_frame, []);
%             hold on
%             plot(centroid_x, centroid_y, 'go')
%             pause
            
            current_image_stacks(image_stack_index).Images(:,:,in_track_index) = worm_frame;
        end
        
        
        tracks_that_end_in_this_frame = find(tracks_end_in_frame(:,frame_index));
        if ~isempty(tracks_that_end_in_this_frame)
            %%%there are tracks that end in this frame, do the computation%%%
            image_stack_indecies = [];
            for ending_track_index = 1:length(tracks_that_end_in_this_frame)
                track_index = tracks_that_end_in_this_frame(ending_track_index);
                image_stack_index = find([current_image_stacks.TrackIndex] == track_index);
                image_stack_indecies = [image_stack_indecies, image_stack_index];
                [Tracks(track_index).Centerlines, Tracks(track_index).CenterlineProperties] = initial_sweep(current_image_stacks(image_stack_index).Images, Tracks(track_index), track_index);
            end
            saved_image_stacks = [saved_image_stacks, current_image_stacks(image_stack_indecies)];
            current_image_stacks(image_stack_indecies) = []; %clear the memory of these images
        end
        
        %frame_index
    end
end