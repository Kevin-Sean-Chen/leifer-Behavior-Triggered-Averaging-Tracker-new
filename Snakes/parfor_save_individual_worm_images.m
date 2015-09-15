function [] = parfor_save_individual_worm_images(Tracks, image_files, medianProj, mask, curDir)
    %DOES NOT WORK
    global WormTrackerPrefs
    AutoThreshold = WormTrackerPrefs.AutoThreshold;
    CorrectFactor = WormTrackerPrefs.CorrectFactor;
    ManualSetLevel = WormTrackerPrefs.ManualSetLevel;
    MaxObjects = WormTrackerPrefs.MaxObjects;
    DarkObjects = WormTrackerPrefs.DarkObjects;
    
    image_size = [70,70];
    frame_count = length(image_files)-1;
    track_count = length(Tracks);
    %parpool(7)
    
    tracks_start_in_frame = logical(sparse(length(Tracks), frame_count));
    tracks_end_in_frame = logical(sparse(length(Tracks), frame_count));
    for track_index = 1:track_count
        tracks_start_in_frame(track_index, Tracks(track_index).Frames(1)) = true;
        tracks_end_in_frame(track_index, Tracks(track_index).Frames(end)) = true;
    end
    
    TracksInFrames(frame_count).TrackIndecies = [];
    current_tracks = [];
    for frame_index = 1:frame_count
        tracks_that_start_in_this_frame = find(tracks_start_in_frame(:,frame_index));
        if ~isempty(tracks_that_start_in_this_frame)
            %%%there are tracks that start in this frame%%%
            previous_length = length(current_tracks);
            current_tracks(previous_length+length(tracks_that_start_in_this_frame)).TrackIndex = []; %preallocate memory
            for new_track_index = 1:length(tracks_that_start_in_this_frame)
                track_index = tracks_that_start_in_this_frame(new_track_index);
                current_tracks(previous_length+new_track_index).TrackIndex = track_index;
                current_tracks(previous_length+new_track_index).TrackStartFrame = frame_index;
            end
        end
        
        TracksInFrames(frame_index).TrackIndecies = [current_tracks.TrackIndex];
        
        tracks_that_end_in_this_frame = find(tracks_end_in_frame(:,frame_index));
        if ~isempty(tracks_that_end_in_this_frame)
            %%%there are tracks that end in this frame, do the computation%%%
            image_stack_indecies = [];
            for ending_track_index = 1:length(tracks_that_end_in_this_frame)
                track_index = tracks_that_end_in_this_frame(ending_track_index);
                image_stack_index = find([current_tracks.TrackIndex] == track_index);
                image_stack_indecies = [image_stack_indecies, image_stack_index];
            end
            current_tracks(image_stack_indecies) = []; %clear the memory of these images
        end
    end
    
    %preallocate memory
    current_image_stacks(track_count).Images = [];
    for track_index = 1:track_count
        current_image_stacks(track_index).Images = uint8(zeros([image_size, length(Tracks(track_index).Frames)]));
    end
    
    try
        mkdir([curDir, '\individual_worm_imgs\']);
    catch
    end
    
    parfor frame_index = 1:frame_count
        %%%image processing%%%
        curImage = imread(image_files(frame_index).name);
        subtractedImage = curImage - uint8(medianProj) - mask; %subtract median projection  - imageBackground
        if AutoThreshold       % use auto thresholding
            Level = graythresh(subtractedImage) + CorrectFactor;
            Level = max(min(Level,1) ,0);
        else
            Level = ManualSetLevel;
        end
        % Convert frame to a binary image 
        NUM = MaxObjects + 1;
        while (NUM > MaxObjects)
            if DarkObjects
                BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
            else
                BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
            end
            % Identify all objects
            [L,NUM] = bwlabel(BW);
            Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
        end

        for tracks_in_frame_index = 1:length(TracksInFrames(frame_index).TrackIndecies)
            track_index = TracksInFrames(frame_index).TrackIndecies(tracks_in_frame_index);
            in_track_index = frame_index - Tracks(track_index).Frames(1) + 1;
            region_index = Tracks(track_index).WormIndex(in_track_index);
            centroid_x = round(Tracks(track_index).Path(in_track_index,1));
            centroid_y = round(Tracks(track_index).Path(in_track_index,2));
            image_top_left_corner_x = centroid_x-image_size(1)/2;
            image_top_left_corner_y = centroid_y-image_size(2)/2;
            image_bottom_right_corner_x = image_top_left_corner_x+image_size(1);
            image_bottom_right_corner_y = image_top_left_corner_y+image_size(2);
            
            cropped_labeled_image = imcrop(L, [image_top_left_corner_x, image_top_left_corner_y, (image_size-1)]);
            single_worm = cropped_labeled_image == region_index; %get an binary mask of only where the worm is
            single_worm = bwmorph(single_worm, 'fill');
            worm_frame = imcrop(subtractedImage, [image_top_left_corner_x, image_top_left_corner_y, (image_size-1)]);
            worm_frame(~single_worm) = 0; %mask

            %pad the image if necessary
            if image_top_left_corner_x < 1 || image_top_left_corner_y < 1
                %pad the front
                worm_frame = padarray(worm_frame, [max(1-image_top_left_corner_y,0), max(1-image_top_left_corner_x,0)], 0, 'pre');
            end
            if image_bottom_right_corner_x > size(L,2) || image_bottom_right_corner_y > size(L,1)
                %pad the end
                worm_frame = padarray(worm_frame, [max(image_bottom_right_corner_y-size(L,1)-1,0), max(image_bottom_right_corner_x-size(L,2)-1,0)], 0, 'post');
            end
   
%             imshow(worm_frame, []);
%             hold on
%             plot(centroid_x, centroid_y, 'go')
%             pause
%             worm_frame = uint8(worm_frame);
            current_image_stacks(track_index).Images(:,:,in_track_index) = uint8(worm_frame);
        end
    end
    
    
    save('current_image_stacks.mat', 'current_image_stacks');
end