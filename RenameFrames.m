folder_name = uigetdir
if folder_name ~= 0
    cd(folder_name) %open the directory of image sequence
    image_files=dir('*.tif'); %get all the tif files
    for frame_index = 1:length(image_files) - 1
        % Get Frame
        Filename = image_files(frame_index).name;
        if strcmp(Filename(1:6), 'Frame_')
            frame_number = str2num(Filename(7:end-4));
            new_name = strcat('Frame_', sprintf('%06d',frame_number), '.tif')
            if ~strcmp(new_name, Filename)
                movefile(image_files(frame_index).name, new_name)
            end
        end
        
    end
end