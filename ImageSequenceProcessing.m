cd('C:\Data\20141112\Data20141112_184206_0.5maxV_2s') %open the directory of image sequence
image_files=dir('*.tif'); %get all the tif files

%get min z projection
minProj = imread(image_files(1).name);
for frame_index = 2:100 %2:length(image_files) - 1
    curImage = imread(image_files(frame_index).name);
    minProj = min(minProj, curImage);
    frame_index
end

%save subtracted avi
outputVideo = VideoWriter(fullfile('processed.avi'),'Grayscale AVI');
outputVideo.FrameRate = 10;
outputVideo.FileFormat
open(outputVideo)

for frame_index = 1:100 %2:length(image_files) - 1
    curImage = imread(image_files(frame_index).name);
    subtractedImage = curImage - minProj;
    %imshow(subtractedImage,[]);
    writeVideo(outputVideo, subtractedImage)
    frame_index
end
close(outputVideo)

shuttleAvi = VideoReader(fullfile('processed.avi'));
ii = 1;
while hasFrame(shuttleAvi)
   mov(ii) = im2frame(readFrame(shuttleAvi));
   ii = ii+1;
end