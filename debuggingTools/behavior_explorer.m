function [newTracks] = behavior_explorer(curDir, Prefs)
% displays a GUI to help user decide how to resolve centerline problems
    min_track_length = Prefs.MinTrackLength;
    if exist([curDir, '\tracks.mat'], 'file') == 2
        load([curDir, '\tracks.mat'])
    else
        return
    end

    for track_index = 1:length(Tracks)
        Track = Tracks(track_index);
        %get the behavior annotations
        
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
                    h = resolve_problems_gui(worm_images, Track, worm_frame_start_index, worm_frame_end_index, track_index);
                    movegui(h, 'center');
                    uiwait(h);
                    action = h.UserData{7};
                    current_frame = h.UserData{6};
                    close(h);
                    switch action
                        %depending on what the user selected, 
                        case 1
                            %no action: repress the error
                            Track.PotentialProblems(worm_frame_start_index:worm_frame_end_index) = -1;
                        case 2
                            %flip head/tail before
                            Track.Centerlines(:,:,1:current_frame) = flip(Track.Centerlines(:,:,1:current_frame),1);
                        case 3
                            %flip head/tail after
                            Track.Centerlines(:,:,current_frame:end) = flip(Track.Centerlines(:,:,current_frame:end),1);
                        case 4
                            %delete track
                            Modifications(modifications_index).TrackIndex = track_index;
                            Modifications(modifications_index).Action = 1; %delete
                            modifications_index = modifications_index + 1;
                            break
                        case 5
                            %delete section and split track
                            Modifications(modifications_index).TrackIndex = track_index;
                            Modifications(modifications_index).Action = 2;
                            Modifications(modifications_index).StartFrame = Track.Frames(worm_frame_start_index);
                            Modifications(modifications_index).EndFrame = Track.Frames(worm_frame_end_index);
                            modifications_index = modifications_index + 1;
                    end
                end
                worm_frame_start_index = worm_frame_end_index + 1;
            end
        end
    end
    
    
end