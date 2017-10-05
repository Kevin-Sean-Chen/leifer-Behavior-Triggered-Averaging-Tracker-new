function [ index_found ] = is_approximate_member(search_for,search_in,min_difference)
%finds if there exists an approximate row in "search_in" for the row "search_for"
    if nargin < 3
        min_difference = 0.95;
    end

    index_found = 0;
    for row_index = 1:size(search_in,1)
        %compute the average L1 distance
        L1_dist = mean(abs(search_for-search_in(row_index,:)));
        if L1_dist < min_difference
            index_found = row_index;
            return
        end
    end
end

