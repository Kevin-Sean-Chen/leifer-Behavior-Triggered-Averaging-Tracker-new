function success = tap_preprocessing(folder_name)
%This function does pre-processing for tap experiments, getting rid of
%motion blurred frames so we don't lose track during taps
    shift = 1;
    
    image_files=dir([folder_name, filesep, '*.jpg']); %get all the jpg files (maybe named tif)
    if isempty(image_files)
        image_files = dir([folder_name, filesep, '*.tif']); 
    end
    
    % Load Voltages
    fid = fopen([folder_name, filesep, 'LEDVoltages.txt']);
    LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
    fclose(fid);
    
    if length(image_files)-1 > length(LEDVoltages)
        %there are more frames than there are stimulus
        success = false;
        return
    end

    savePath = [folder_name, filesep, 'back_up_images', filesep];
    if ~exist(savePath, 'dir')
        mkdir(savePath)
    end
    
    tap_indecies = find(LEDVoltages > 0);
    
    for tap_index = 1:length(tap_indecies)
        %loop through every time the tapper actuates
        blurred_image_index = tap_indecies(tap_index)+shift; %apply shift
        if blurred_image_index > 2 && blurred_image_index < length(LEDVoltages)
            %ignore if the experiment begins with a tap or ends with a tap
            filename = [folder_name, filesep, image_files(blurred_image_index).name];
            if ~strcmp(filename(end-4),'s')
                %the filename does not end with s, save back up file, and
                %replace it with the previous frame
                movefile(filename,[savePath, image_files(blurred_image_index).name],'f');            
                new_file_name = [folder_name, filesep, image_files(blurred_image_index).name(1:end-4), 's', ...
                image_files(blurred_image_index).name(end-3:end)];
                copyfile([folder_name, filesep, image_files(blurred_image_index-1).name],...
                new_file_name,'f');
            end
        end
    end
    success = true;
end

