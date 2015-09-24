function [] = rename_individual_worm_images(curDir, beginIndex, endIndex, shift)
% renames the individually saved matrices by shift
    if shift > 0
        %shift up
        shift_indecies = endIndex:-1:beginIndex;
    elseif shift < 0
        %shift down
        shift_indecies = beginIndex:endIndex;
    else
        return
    end

    for track_index = shift_indecies
        current_file_name = [curDir, '\individual_worm_imgs\worm_', num2str(track_index), '.mat'];
        if ~exist(current_file_name, 'file')
            break;
        end
        new_file_name = [curDir, '\individual_worm_imgs\worm_', num2str(track_index+shift), '.mat'];
        movefile(current_file_name, new_file_name, 'f');
    end
end