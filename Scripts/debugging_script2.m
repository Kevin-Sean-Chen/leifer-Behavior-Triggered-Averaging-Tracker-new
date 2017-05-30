%plot major watershed divisions
for behavior_group_index = 1:length(behavior_group)
    combined_L = combine_watersheds(L, behavior_group{behavior_group_index});
    combined_binary_L = combined_L == 0;
    dilated_combined_binary_L = imdilate(combined_binary_L,ones(3));
    inner_border_L = and(ismember(L,behavior_group{behavior_group_index}), dilated_combined_binary_L);
    imshow(inner_border_L);
    
end