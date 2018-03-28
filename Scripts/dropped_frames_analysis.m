folder_name = uigetdir;

image_files=dir([folder_name, filesep, '*.jpg']); %get all the jpg files (maybe named tif)
if isempty(image_files)
    image_files = dir([folder_name, filesep, '*.tif']); 
end

image_indecies = zeros(1,length(image_files));
for frame_index = 1:length(image_files)
   image_indecies(frame_index) = str2double(image_files(frame_index).name(7:end-4));
end

frame_diff = diff(image_indecies);
dropped_event_indecies = find(frame_diff>1);
dropped_frames = frame_diff(dropped_event_indecies);
dropped_event_frame_diff = diff(dropped_event_indecies)
hist(dropped_frames)