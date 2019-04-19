relevant_track_fields = {'Size','Frames'};

%select folders
folders = getfoldersGUI();

[allTracks, folder_indecies, track_indecies] = loadtracks(folders,relevant_track_fields );

worm_sizes = zeros(1,length(allTracks));

for track_index = 1:length(allTracks)
   worm_sizes(track_index) = mean(allTracks(track_index).Size); 
end

hist(worm_sizes,100)
xlabel('Size (pixels)')
ylabel('Count (tracks)')