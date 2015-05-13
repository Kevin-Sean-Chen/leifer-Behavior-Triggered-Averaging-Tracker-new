function [Rate, reversal_counts, frame_count]= ReversalRate(folders, bin_size)
    fps = 14;
    reversal_counts = [];
   
    
    if nargin < 1 %no folders are given, ask user to select
        folders = {};
        while true
            folder_name = uigetdir
            if folder_name == 0
                break
            else
                folders{length(folders)+1} = folder_name;
            end
        end
    end
    
    if nargin < 2 %no bin number specified
        bin_size = fps; %default bin size is one bin per min
    end
    
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        try
            load('parameters.txt')
            frames = parameters(length(parameters));
        catch
            parameters = readtable('parameters.txt', 'Delimiter', '\t');
            frames = parameters{1,{'FrameCount'}};
        end

        if isempty(reversal_counts)
            %divide bins by minute
            reversal_counts = zeros(1, ceil(frames) / bin_size);
            frame_count = zeros(1, ceil(frames) / bin_size);
            tracksCentered = [];
            pirouetteCount = 0;
        end
        allTracks = Tracks;
        for track = 1:length(allTracks)
            pirouettes = allTracks(track).Pirouettes;
            frames = allTracks(track).Frames;
            for pirouette_index = 1:size(pirouettes,1)
                pirouetteStart = pirouettes(pirouette_index,1);
                reversal_counts(ceil(frames(pirouetteStart) / bin_size)) = reversal_counts(ceil(frames(pirouetteStart) / bin_size)) + 1;
            end
            for frame_index = 1:length(frames)
                frame_count(ceil(frames(frame_index) / bin_size)) = frame_count(ceil(frames(frame_index) / bin_size)) + 1;
            end
        end
    end
    Rate = reversal_counts./frame_count * fps * 60;
    Rate(isnan(Rate)) = 0; %replace nan with 0

    if nargin < 1
        figure
        plot(Rate, 'bo-')
        %legend(num2str(tracksByVoltage(voltage_index).voltage));
        xlabel(['minutes (', num2str(sum(reversal_counts)), ' reversals analyzed) average reversal rate = ', num2str(sum(reversal_counts)/sum(frame_count)* fps * 60)]) % x-axis label
        ylabel('reversals per worm per min') % y-axis label
        axis([1 frames/bin_size 0 3])
    end
end