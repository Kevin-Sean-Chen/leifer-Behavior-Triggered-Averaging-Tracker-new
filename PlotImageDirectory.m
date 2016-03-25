function success = PlotImageDirectory(curDir, Prefs)
% plots the individual worm videos and all the track videos

    %% STEP 1: initialize %%
    number_of_images_for_median_projection = 20;
    mask = Prefs.Mask;

    if exist([curDir, '\tracks.mat'], 'file') == 2
        load([curDir, '\tracks.mat'])
    else
        success = false;
        return
    end
    
    %% STEP 2: plot individual worms
    if Prefs.IndividualVideoPlottingFrameRate > 0
        individual_worm_videos(Tracks, curDir, Prefs.SampleRate, Prefs.IndividualVideoPlottingFrameRate);
    end
    
    %% STEP 3: Load images and other properties from the directory %%
    % check if preferences indicate not to plot
    if Prefs.PlottingFrameRate <= 0
        return
    end
    
    % Get all the tif file names (probably jpgs)
    image_files = dir([curDir, '\*.tif']); 
    % Load Voltages
    fid = fopen([curDir, '\LEDVoltages.txt']);
    LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
    fclose(fid);
    
    %% STEP 4: Get the median z projection %%
    medianProj = imread([curDir, '\', image_files(1).name]);
    medianProjCount = min(number_of_images_for_median_projection, length(image_files) - 1); 
    medianProj = zeros(size(medianProj,1), size(medianProj,2), medianProjCount);
    for frame_index = 1:medianProjCount
        curImage = imread([curDir, '\', image_files(floor((length(image_files)-1)*frame_index/medianProjCount)).name]);
        medianProj(:,:,frame_index) = curImage;
    end
    medianProj = median(medianProj, 3);
    medianProj = uint8(medianProj);
    
    %% STEP 5: plot all the tracks
    % Setup figure for plotting tracker results
    % -----------------------------------------
    WTFigH = findobj('Tag', 'WTFIG');
%     preprocessedFigH = findobj('Tag', 'preprocessedFig');
%     if isempty(preprocessedFigH)
%         preprocessedFigH = figure('Name', 'Raw Video', ...
%             'NumberTitle', 'off', ...
%             'Tag', 'preprocessedFig');
%     else
%         figure(preprocessedFigH);
%     end
    if isempty(WTFigH)
        WTFigH = figure('Name', 'Tracking Results', ...
            'NumberTitle', 'off', ...
            'Tag', 'WTFIG');
    else
        figure(WTFigH);
    end

    frames_per_plot_time = round(Prefs.SampleRate/Prefs.PlottingFrameRate);
    
    %save subtracted avi
    outputVideo = VideoWriter(fullfile([curDir, '\', 'processed']),'MPEG-4');
    outputVideo.FrameRate = Prefs.PlottingFrameRate;
    open(outputVideo)
    
%     rawOutputVideo = VideoWriter(fullfile([curDir, '\', 'raw']),'MPEG-4');
%     rawOutputVideo.FrameRate = Prefs.PlottingFrameRate;
%     open(rawOutputVideo)
    
    for frame_index = 1:frames_per_plot_time:length(image_files) - 1
        % Get Frame
        curImage = imread([curDir, '\', image_files(frame_index).name]);
        subtractedImage = curImage - uint8(medianProj) - mask; %subtract median projection  - imageBackground
        if Prefs.AutoThreshold       % use auto thresholding
            Level = graythresh(subtractedImage) + Prefs.CorrectFactor;
            Level = max(min(Level,1) ,0);
        else
            Level = Prefs.ManualSetLevel;
        end
        % Convert frame to a binary image 
        NUM = Prefs.MaxObjects + 1;
        while (NUM > Prefs.MaxObjects)
            if Prefs.DarkObjects
                BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
            else
                BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
            end

            % Identify all objects
            [~,NUM] = bwlabel(BW);
            Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
        end

        PlotFrame(WTFigH, double(BW), Tracks, frame_index, LEDVoltages(frame_index));
        FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
        set(WTFigH, 'Name', FigureName);
        writeVideo(outputVideo, getframe(WTFigH));
        
%         figure(preprocessedFigH)
%         imshow(curImage);
%         writeVideo(rawOutputVideo, getframe(preprocessedFigH));
    end
    close(outputVideo) 
%     close(rawOutputVideo)
    close(WTFigH)
end
