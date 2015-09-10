function [predicted_head, predicted_tail] = predict_tips(previous_centerlines)
    nPoints = size(previous_centerlines, 1);
%     
%     %get rid of empty centerlines
%     head_x = squeeze(previous_centerlines(1,1,:));
%     non_zero_elements = find(head_x);
%     previous_centerlines = previous_centerlines(:,:,non_zero_elements);
% 
%     
%     if size(previous_centerlines,3) == 1
%         %only one centerline is available   
        predicted_head = reshape(previous_centerlines(1,:,end),1,2);
        predicted_tail = reshape(previous_centerlines(nPoints,:,end),1,2);
%         return
%     end
% 
%     heads = squeeze(previous_centerlines(1,:,:))';
%     heads_mean = mean(heads,1);
%     heads_diff = diff(heads,1,1);
%     heads_diff_mean = mean(heads_diff,1);
%     predicted_head = heads_mean + (heads_diff_mean*length(non_zero_elements)/2);
%     
%     tails = squeeze(previous_centerlines(nPoints,:,:))';
%     tails_mean = mean(tails,1);
%     tails_diff = diff(tails,1,1);
%     tails_diff_mean = mean(tails_diff,1);
%     predicted_tail = tails_mean + (tails_diff_mean*length(non_zero_elements)/2);
end