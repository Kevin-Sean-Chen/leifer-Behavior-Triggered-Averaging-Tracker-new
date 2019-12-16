%Analyze error tracks
%%% this code is to analyze the deleted tracks to figure out main reasons
%%% tracking fails...

load('Z:\Kevin\20191213_GWN_N2_test\Data20191213_181914\tracking_deleted_tracks.mat')
%% read in the deleted tracks and c
all_reasons = extractfield(deleted_tracks,'DeletionReason');
all_possible_errors = unique(all_reasons);  %{'Short Displacement ', 'Short Track length '};
all_reasons_int = zeros(1,length(all_reasons));

for d = 1:length(all_reasons)
    
    reason = all_reasons(d);
    if strcmp(cell2mat(reason),(all_possible_errors{1}))==1
        all_reasons_int(d) = 1;
    elseif strcmp(cell2mat(reason),(all_possible_errors{2}))==1
        all_reasons_int(d) = 2;
    end
    
end

figure;
histogram(all_reasons_int)

%% distribution of track lengths
lens = zeros(1,length(deleted_tracks)); 
for d = 1:length(deleted_tracks)
    lens(d) = length(deleted_tracks(d).Frames); 
end

figure;
histogram(lens)


