%% load Tracks
relevant_track_fields = {'BehavioralTransition','Frames','LEDPower','LEDVoltage2Power'};    

%select folders
folders_GWN_ret = getfoldersGUI();
% folders_GWN_noret = getfoldersGUI();
% folders_tri_ret = getfoldersGUI();

%ret
[allTracks_GWN_ret, folder_indecies_GWN_ret, track_indecies_GWN_ret] = loadtracks(folders_GWN_ret,relevant_track_fields);
%noret
%[allTracks_GWN_noret, folder_indecies_GWN_noret, track_indecies_GWN_noret] = loadtracks(folders_GWN_noret,relevant_track_fields);
% %triangleret
% [allTracks_tri_ret, folder_indecies_tri_ret, track_indecies_tri_ret] = loadtracks(folders_tri_ret,relevant_track_fields);

load('reference_embedding.mat')
number_of_behaviors = max(L(:))-1;
% allTracks = [allTracks_GWN_ret, allTracks_GWN_noret];
% folders = [folders_GWN_ret, folders_GWN_noret];
% folder_indecies = [folder_indecies_GWN_ret, folder_indecies_GWN_noret+folder_indecies_GWN_ret(end)];
% track_indecies = [track_indecies_GWN_ret, track_indecies_GWN_noret];


%get LNPs
[LNPStats_nondirectional_ret, meanLEDPower_nondirectional_ret, stdLEDPower_nondirectional_ret] = FitLNP(allTracks_GWN_ret,folder_indecies_GWN_ret,folders_GWN_ret);
[LNPStats_directional_ret, meanLEDPower_directional_ret, stdLEDPower_directional_ret] = directional_FitLNP(allTracks_GWN_ret,folder_indecies_GWN_ret,folders_GWN_ret);

PlotBehavioralMappingExperimentGroup(LNPStats_nondirectional_ret, meanLEDPower_nondirectional_ret, stdLEDPower_nondirectional_ret, L, density, xx)
PlotDirectionalBehavioralMappingExperimentGroup(LNPStats_directional_ret, meanLEDPower_directional_ret, stdLEDPower_directional_ret, L, density, xx)

%% compare behavioral rates for ret and noret GWN conditions
% behavioral rates
[behavioral_transition_rates_ret,behavioral_transition_rates_std_ret,behavior_occupation_ratio_ret] = find_behavioral_rates(allTracks_GWN_ret);
[behavioral_transition_rates_noret,behavioral_transition_rates_std_noret,behavior_occupation_ratio_noret] = find_behavioral_rates(allTracks_GWN_noret);

figure
hold on
errorbar(1:length(behavioral_transition_rates_ret),behavioral_transition_rates_ret,behavioral_transition_rates_std_ret,'r.','linewidth',1,'markersize',10)
errorbar(1:length(behavioral_transition_rates_noret),behavioral_transition_rates_noret,behavioral_transition_rates_std_noret,'b.','linewidth',1,'markersize',10)

legend({'GWN ret', 'GWN noret'})
xlabel('Behavior Index')
ylabel('Transition Rate (transitions/min)')


% 
% %% load GWN tracks by day and compare day to day variations
% folders_GWN_ret_day1 = getfoldersGUI();
% folders_GWN_ret_day2 = getfoldersGUI();
% folders_GWN_ret_day3 = getfoldersGUI();
% 
% %day 1
% [allTracks_GWN_ret_day1, folder_indecies_GWN_ret_day1, track_indecies_GWN_ret_day1] = loadtracks(folders_GWN_ret_day1,relevant_track_fields);
% %day 2
% [allTracks_GWN_ret_day2, folder_indecies_GWN_ret_day2, track_indecies_GWN_ret_day2] = loadtracks(folders_GWN_ret_day2,relevant_track_fields);
% %day 3
% [allTracks_GWN_ret_day3, folder_indecies_GWN_ret_day3, track_indecies_GWN_ret_day3] = loadtracks(folders_GWN_ret_day3,relevant_track_fields);
% 
% % behavioral density
% figure
% PlotWatershed(vertcat(allTracks_GWN_ret_day1(:).Embeddings));
% figure
% PlotWatershed(vertcat(allTracks_GWN_ret_day2(:).Embeddings));
% figure
% PlotWatershed(vertcat(allTracks_GWN_ret_day3(:).Embeddings));
% 
% % behavioral rates
% [behavioral_transition_rates_day1,behavioral_transition_rates_std_day1,behavior_occupation_ratio_day1] = find_behavioral_rates(allTracks_GWN_ret_day1);
% [behavioral_transition_rates_day2,behavioral_transition_rates_std_day2,behavior_occupation_ratio_day2] = find_behavioral_rates(allTracks_GWN_ret_day2);
% [behavioral_transition_rates_day3,behavioral_transition_rates_std_day3,behavior_occupation_ratio_day3] = find_behavioral_rates(allTracks_GWN_ret_day3);
% 
% figure
% hold on
% errorbar(1:length(behavioral_transition_rates_day1),behavioral_transition_rates_day1,behavioral_transition_rates_std_day1,'r.','linewidth',1,'markersize',10)
% errorbar(1:length(behavioral_transition_rates_day2),behavioral_transition_rates_day2,behavioral_transition_rates_std_day2,'b.','linewidth',1,'markersize',10)
% errorbar(1:length(behavioral_transition_rates_day3),behavioral_transition_rates_day3,behavioral_transition_rates_std_day3,'g.','linewidth',1,'markersize',10)
% legend({'day 1', 'day 2', 'day 3'})
% xlabel('Behavior Index')
% ylabel('Transition Rate (transitions/min)')
% 
% %occupation ratio
% figure
% pie(behavior_occupation_ratio_day1)
% legend({'behavior 1', 'behavior 2', 'behavior 3','behavior 4', 'behavior 5', 'behavior 6', ...
%     'behavior 7', 'behavior 8', 'behavior 9', 'unassigned frames'})
% figure
% pie(behavior_occupation_ratio_day2)
% legend({'behavior 1', 'behavior 2', 'behavior 3','behavior 4', 'behavior 5', 'behavior 6', ...
%     'behavior 7', 'behavior 8', 'behavior 9', 'unassigned frames'})
% figure
% pie(behavior_occupation_ratio_day3)
% legend({'behavior 1', 'behavior 2', 'behavior 3','behavior 4', 'behavior 5', 'behavior 6', ...
%     'behavior 7', 'behavior 8', 'behavior 9', 'unassigned frames'})
% 
% %% playing with ML estimation
% % figure
% % [X_subsampled,indecies_picked] = datasample(X,floor(size(X,1)./100),1,'Replace',false);
% % Y_subsampled = Y(indecies_picked,:);
% % Behavior_triggered_X = X_subsampled(Y_subsampled(:,9),:);
% % BTA = mean(Behavior_triggered_X,1);
% % plot(BTA)
% 
% [LNPStats, meanLEDPower_nondirectional_ret, stdLEDPower_nondirectional_ret] = ML_FitLNP(folders_GWN_ret);
% 
% PlotBehavioralMappingExperimentGroup (LNPStats, 0, stdLEDPower_nondirectional_ret, L, density, xx)