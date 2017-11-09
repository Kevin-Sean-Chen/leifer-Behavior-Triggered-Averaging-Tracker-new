function [percent_change, baselines, max_beyond_baseline, min_beyond_baseline] = percent_change_above_baseline(data)
%finds a baseline value by averaging the first part of the data, finds
%the max deviation from baseline, and calculate how much deviation occurs
    baseline_ratio = 0.2;
    search_until = 0.8;
    baseline_cutoff = round(size(data,2) .* baseline_ratio);
    search_until_cutoff = round(size(data,2) .* search_until);
    
    baselines = mean(data(:,1:baseline_cutoff),2);
    max_beyond_baseline = max(data(:,baseline_cutoff+1:search_until_cutoff),[],2);
    min_beyond_baseline = min(data(:,baseline_cutoff+1:search_until_cutoff),[],2);
    
    max_change = (max_beyond_baseline - baselines) ./ baselines .* 100;
    min_change = (baselines - min_beyond_baseline) ./ baselines .* 100;
    
    percent_change = zeros(size(baselines));
    for behavior_index = 1:size(data,1)
        if max_change(behavior_index) > min_change(behavior_index)
            percent_change(behavior_index) = max_change(behavior_index);
        else
            percent_change(behavior_index) = -min_change(behavior_index);
        end
    end
    

end

