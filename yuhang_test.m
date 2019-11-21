%% Select data folder (and subfolders) to work with
folders = getfoldersGUI();
%% Extract tracks for a time window around the sti
load('reference_embedding.mat')

relevant_fields = {'Frames','BehavioralTransition','Behaviors','LEDVoltages','TapVoltages','LEDPower'};
Tracks = loadtracks(folders, relevant_fields);
Tracks=BehavioralTransitionToBehavioralAnnotation(Tracks);
n_tracks=length(Tracks);
% Look for turning
track_index = 3;
turning_frames=Tracks(track_index).Frames(Tracks(track_index).Behaviors(9,:));

[sti_tracks,TAPonly_tracks,LEDonly_tracks]=get_tracks_with_sti(Tracks);
%% Create behavior profile 
[behavior_ratios_for_frame,transition_rate_for_frame]=get_behavior_window(sti_tracks);
%% Plot
my_colors = behavior_colors;
plot_frames=(-139:140)./14;
figure
hold on
for behavior_index = 1:number_of_behaviors
    plot(plot_frames, behavior_ratios_for_frame(behavior_index,:), '-', 'color', my_colors(behavior_index,:),'Linewidth', 3,'DisplayName',behavior_names{behavior_index});
end
hold off
%title(['(n = ', num2str(track_n), ' tracks)']);
xlabel('Time (s)') % x-axis label
ylabel('Behavioral Ratio') % y-axis label
legend('show');
ax = gca;
ax.FontSize = 10;

%% Separate Tracks based on LEDPower
power_list=[];
threshold_power=[0.8 1.2];
for i=1:length(sti_tracks) %get the power list
    current_track=sti_tracks(i);
    power=round(max(current_track.LEDPower));
    if ~ismember(power,power_list)
        power_list=[power_list, power];
    end
end
n_power=length(power_list);
max_reverse_ratio=zeros(1,n_power);
for i=1:n_power
    p=power_list(i);
    temp_tracks=struct([]);
    for k=1:length(sti_tracks)
        current_track=sti_tracks(k);
        this_power=round(max(current_track.LEDPower));
        if this_power==p
            temp_tracks=[temp_tracks,current_track];
        end
    end
    [behavior_ratios,transition_rate]=get_behavior_window(temp_tracks);
    max_reverse_ratio(i)=max(behavior_ratios(8,:));
    
end
%% plot reverse ratio vs light power
power_vs_reverse=cat(1,power_list,max_reverse_ratio);
power_vs_reverse=power_vs_reverse';
power_vs_reverse=sortrows(power_vs_reverse);
% delete rows with 0 ratio
power_vs_reverse((power_vs_reverse(:,2)==0),:)=[];
figure
plot(power_vs_reverse(:,1),power_vs_reverse(:,2))
%% sort
[power_list_sort,sort_index]=sort(power_list);
max_reverse_ratio=max_reverse_ratio(sort_index);
figure
plot(power_list_sort,max_reverse_ratio)
%% Chceck LEDonly_tracks is free of taps
ss=0;
for i=1:length(LEDonly_tracks)
    current_track=LEDonly_tracks(i);
    ss=ss+sum(current_track.TapVoltages);
end
ss
%% 
ss=0;
for i=1:length(TAPonly_tracks)
    current_track=TAPonly_tracks(i);
    ss=ss+sum(current_track.LEDVoltages);
end
ss

%% save noR data
x_nor=x;
y_nor=y2;
sem_nor=sem;
n_tracks_nor=n_tracks;
n_sti_nor=length(x_nor);
save('nor_data.mat','x_nor','y_nor','sem_nor','n_tracks_nor','n_sti_nor');
whos('-file','nor_data.mat')
%% save ret data
x_ret=x;
y_ret=y2;
sem_ret=sem;
n_tracks_ret=n_tracks;
n_sti_ret=length(x_ret);
save('ret_data.mat','x_ret','y_ret','sem_ret','n_tracks_ret','n_sti_ret');
whos('-file','ret_data.mat')
%% overlay ret and noR plots
load('ret_data.mat');load('nor_data.mat');
figure('Position',[100,100,800,600])
errorbar(x_nor, y_nor,sem_nor, 'ko-', 'LineWidth',2,'Markersize',10)
hold on
errorbar(x_ret, y_ret,sem_ret, 'bo-', 'LineWidth',2,'Markersize',10)
grid on
for stimulus_index = 1:n_sti_nor
    text(x_nor(stimulus_index), y_nor(stimulus_index), ['   n=', num2str(n_tracks_nor(stimulus_index))]);
end
for stimulus_index = 1:n_sti_ret
    text(x_ret(stimulus_index), y_ret(stimulus_index), ['   n=', num2str(n_tracks_ret(stimulus_index))]);
end
ax = gca;
ax.XTick = stimulus_intensities;
% ax.YTick = [0 0.3 0.6];
ax.FontSize = 20;
xlabel('Stimulus Intensity (uW/mm2)') % x-axis label
ylabel('Fast Reverse Behavioral Ratio') % y-axis label
title('Behavior Responses vs Light Intensities');
ylim([0.25,0.7]);
legend('No Retinal','Retinal')
