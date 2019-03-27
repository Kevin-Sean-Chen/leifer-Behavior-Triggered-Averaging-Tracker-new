%function [] = centerline_checker(curDir)
% displays a GUI to view problems in the centerline
    %if nargin == 0
        %allow user to select directory
        %curDir = uigetdir
    %end
        
    %Tracks = loadtracks(curDir);

    for track_index = 1:length(Tracks)
        Track = Tracks(track_index);
        
        potential_problems = Track.PotentialProblems;
        if sum(potential_problems) > 0
            loaded_file = load([curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat']);
            worm_images = loaded_file.worm_images;

            frames_to_show = conv(single(potential_problems), ones(1, 28), 'same'); %show for 2 sec around the problem
            frames_to_show = frames_to_show > 0;
            worm_frame_start_index = 0;
            while worm_frame_start_index <= size(worm_images, 3)
                [worm_frame_start_index, worm_frame_end_index] = find_next_section(frames_to_show, worm_frame_start_index, 'f');
                if isempty(worm_frame_start_index)
                    break
                else
                    %call the gui for resolution
                    h = behavior_explorer_gui(worm_images, Track, worm_frame_start_index, worm_frame_end_index, track_index);
                    movegui(h, 'center');
                    uiwait(h);
                    action = h.UserData{7};
                    current_frame = h.UserData{6};
                    close(h);
                end
                worm_frame_start_index = worm_frame_end_index + 1;
            end
        end
    end
    
    
%end