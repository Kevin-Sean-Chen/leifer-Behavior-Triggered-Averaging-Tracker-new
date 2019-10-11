function success = plot_image_directory(folder_name)
% plots the individual worm videos and all the track videos

    addpath(genpath(pwd))

    %% STEP 1: initialize %%
    number_of_images_for_median_projection = 20;
    parameters = load_parameters(folder_name); %load experiment parameters
%     inset_magification = 10;
    % parameters.PlottingFrameRate = 14;
    
    mask = parameters.Mask;
    
    if parameters.IndividualVideoPlottingFrameRate > 0
        %plot individual worms
        relevant_track_fields = {'Centerlines','UncertainTips','Eccentricity',...
            'Direction','Speed','TotalScore','Active','Path','LastCoordinates',...
            'Frames','NumFrames','Pirouettes','Runs','Size','SmoothSpeed','AngSpeed'};
    else
        %plot whole field only
        relevant_track_fields = {'Active','Path','LastCoordinates',...
            'Frames','NumFrames','Pirouettes','Runs','Size','SmoothSpeed','AngSpeed'};        
    end
    %% Load tracks
    Tracks = load_single_folder(folder_name, relevant_track_fields);
    if isempty(Tracks)
        error('Empty Tracks');
    end

    %% STEP 2: plot individual worms
    if parameters.IndividualVideoPlottingFrameRate > 0
        individual_figure = figure;
        individual_worm_videos(Tracks, folder_name, parameters.SampleRate, parameters.IndividualVideoPlottingFrameRate);
        close(individual_figure)
    end
    
    %% STEP 3: Load images and other properties from the directory %%
    % check if preferences indicate not to plot
    if parameters.PlottingFrameRate <= 0
        success = true;
        return
    end
    
    % Get all the tif file names (probably jpgs)
    image_files=dir([folder_name, filesep, '*.jpg']); %get all the jpg files (maybe named tif)
    if isempty(image_files)
        image_files = dir([folder_name, filesep, '*.tif']); 
    end
    
    % Load Voltages
    if exist([folder_name, filesep, 'LEDVoltages.txt'], 'file') == 2
        fid = fopen([folder_name, filesep, 'LEDVoltages.txt']);
        LEDVoltages = transpose(cell2mat(textscan(fid,'%f','HeaderLines',0,'Delimiter','\t'))); % Read data skipping header
        fclose(fid);
        if length(LEDVoltages) > length(image_files) && mod(length(LEDVoltages),length(image_files)) == 0
            %reshape LEDVoltages in multistim mode
            LEDVoltages = reshape(LEDVoltages,[length(LEDVoltages)/length(image_files),length(image_files)]);
        end
    else
        LEDVoltages = zeros(1,length(image_files)-1);
    end
    
    
    LEDPowers = LEDVoltages(1,:) ./ 5 .* parameters.avgPower500; %only thake the first power for plotting
    
    % Load deleted tracks if we are debugging mode
    all_deleted_tracks = [];
    if parameters.TrackingDebugMode
        deleted_track_file_name = [folder_name, filesep, 'tracking_deleted_tracks.mat'];
        if exist(deleted_track_file_name, 'file') == 2
            load(deleted_track_file_name);
        end
        all_deleted_tracks = deleted_tracks;
        deleted_track_file_name = [folder_name, filesep, 'centerline_deleted_tracks.mat'];
        if exist(deleted_track_file_name, 'file') == 2
            load(deleted_track_file_name);
        end
        for track_index = 1:length(deleted_tracks)
            deleted_tracks(track_index).DeletionReason = 'Low Centerline Score';
        end
        all_deleted_tracks = [all_deleted_tracks, deleted_tracks];
        clear deleted_tracks
    end
    
    %% STEP 4: Get the median z projection %%
    medianProj = imread([folder_name, filesep, image_files(1).name]);
    medianProjCount = min(number_of_images_for_median_projection, length(image_files) - 1); 
    medianProj = zeros(size(medianProj,1), size(medianProj,2), medianProjCount);
    for frame_index = 1:medianProjCount
        curImage = imread([folder_name, filesep, image_files(floor((length(image_files)-1)*frame_index/medianProjCount)).name]);
        medianProj(:,:,frame_index) = curImage;
    end
    medianProj = median(medianProj, 3);
    medianProj = uint8(medianProj);
    
    %% STEP 5: plot all the tracks
    % Setup figure for plotting tracker results
    % -----------------------------------------
    WTFigH = findobj('Tag', 'WTFIG');
    if isempty(WTFigH)
        WTFigH = figure('Name', 'Tracking Results', ...
            'NumberTitle', 'off', ...
            'Tag', 'WTFIG','units','normalized','outerposition',[0 0 2 2]);
    else
        figure(WTFigH);
    end

    frames_per_plot_time = round(parameters.SampleRate/parameters.PlottingFrameRate);
    
    %save subtracted avi
%    outputVideo = VideoWriter(fullfile([folder_name, filesep, 'processed']),'MPEG-4');
    outputVideo = VideoWriter(fullfile([folder_name, filesep, 'processed']),'Motion JPEG AVI');
%     outputVideo.Quality = 100;
    outputVideo.FrameRate = parameters.PlottingFrameRate;
    open(outputVideo)
    
    current_track = 0;
    
    for frame_index = 1:frames_per_plot_time:length(image_files) - 1
        % Get Frame
        curImage = imread([folder_name, filesep, image_files(frame_index).name]);
        if parameters.PlottingRawImage
            active_tracks = PlotFrame(WTFigH, curImage, Tracks, frame_index, LEDPowers(frame_index), all_deleted_tracks);
        else
            subtractedImage = curImage - uint8(medianProj) - mask; %subtract median projection  - imageBackground
            if parameters.AutoThreshold       % use auto thresholding
                Level = graythresh(subtractedImage) + parameters.CorrectFactor;
                Level = max(min(Level,1) ,0);
            else
                Level = parameters.ManualSetLevel;
            end
            % Convert frame to a binary image 
            NUM = parameters.MaxObjects + 1;
            while (NUM > parameters.MaxObjects)
                if parameters.DarkObjects
                    BW = ~im2bw(subtractedImage, Level);  % For tracking dark objects on a bright background
                else
                    BW = im2bw(subtractedImage, Level);  % For tracking bright objects on a dark background
                end

                % Identify all objects
                [~,NUM] = bwlabel(BW);
                Level = Level + (1/255); %raise the threshold until we get below the maximum number of objects allowed
            end

    %         active_tracks = PlotFrame(WTFigH, double(BW), Tracks, frame_index, LEDPowers(frame_index));
            active_tracks =  PlotFrame(WTFigH, subtractedImage, Tracks, frame_index, LEDPowers(frame_index), all_deleted_tracks);
        end
%         if ~isempty(active_tracks)
%             %draw inset video
%             figure(WTFigH);
%             axis manual;
%             hold on;
%             % get the smallest active track
%             if current_track == 0 || frame_index > max(Tracks(current_track).Frames)
%                 current_track = min(active_tracks);
%                 loaded_file = load([folder_name, filesep, 'individual_worm_imgs', filesep, 'worm_', num2str(current_track), '.mat']);
%                 worm_images = loaded_file.worm_images;
%             end
%             in_track_index = frame_index-Tracks(current_track).Frames(1)+1;
%             I = squeeze(worm_images(:,:,in_track_index));
%             I_resize = imresize(I, size(I).*inset_magification);
%             imshow(imadjust(I_resize));
%             rectangle('Position',[0,0,size(I_resize)],'EdgeColor', 'g', 'LineWidth',5,'LineStyle','-')
%             rectangle('Position',[Tracks(current_track).Path(in_track_index,1)-(size(I,1)/2),Tracks(current_track).Path(in_track_index,2)-(size(I,2)/2),size(I)],'EdgeColor', 'g', 'LineWidth',2,'LineStyle','-')
%             hold off
%         end
        FigureName = ['Tracking Results for Frame ', num2str(frame_index)];
        set(WTFigH, 'Name', FigureName);
        writeVideo(outputVideo, getframe(WTFigH));
        
    end
    close(outputVideo) 
    close(WTFigH)
    success = true;
end
