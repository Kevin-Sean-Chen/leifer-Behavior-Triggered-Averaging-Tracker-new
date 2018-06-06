%% combine watersheds to generate behavior map for forward, reverse, turns
combined_L = combine_watersheds(L, [7,8]);
L = combine_watersheds(combined_L, [1,2,3,4,5,6]);
behavior_names = {'Forward', 'Reverse', 'Turns'};
behavior_colors = [1,0.466666666666667,0.466666666666667; 0.196078431372549,0.196078431372549,1; 0.854901960784314,0.00392156862745098,0.921568627450980];
