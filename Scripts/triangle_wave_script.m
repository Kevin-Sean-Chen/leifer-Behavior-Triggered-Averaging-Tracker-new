%not used in paper

folders_tri_ret = getfoldersGUI();
load('reference_embedding.mat')
relevant_track_fields = {'BehavioralTransition','Path','Frames','LEDPower','LEDVoltages','Embeddings','Velocity', 'LEDVoltage2Power'};

[allTracks_tri_ret, folder_indecies, track_indecies ] = loadtracks(folders_tri_ret,relevant_track_fields);
%% calculate directional behaviors for triangle waves
%get the number of behaviors
number_of_behaviors = max(L(:))-1;
clear all_transitions

%get transition graph
transition_graph = BehavioralTransitionGraph(allTracks_tri_ret, number_of_behaviors, false, 1);

%get a list of behavioral triggers
edges = table2array(transition_graph.Edges);
edges = sortrows(edges, 2); %sort the edges by going into
no_weight_edges = edges(:,1:2);
allTracks_tri_ret(1).Behaviors = [];
number_of_edges = size(no_weight_edges,1);

for track_index = 1:length(allTracks_tri_ret)
    triggers = false(number_of_edges, length(allTracks_tri_ret(track_index).Frames)); %a binary array of when behaviors occur
    for edge_index = 1:number_of_edges
        current_behavioral_transition = allTracks_tri_ret(track_index).BehavioralTransition(:,1)';
        transition_indecies = strfind(current_behavioral_transition,no_weight_edges(edge_index,:))+1;
        %transition into
        transition_start_frames = allTracks_tri_ret(track_index).BehavioralTransition(transition_indecies,2);
        triggers(edge_index,transition_start_frames) = true;
    end
    allTracks_tri_ret(track_index).Behaviors = triggers(:,1:length(allTracks_tri_ret(track_index).Frames));
end

%% calculate the triggers for LNP fitting without direction
number_of_behaviors = max(L(:)-1);
allTracks_tri_ret(1).Behaviors = [];
for track_index = 1:length(allTracks_tri_ret)
    triggers = false(number_of_behaviors, length(allTracks_tri_ret(track_index).Frames)); %a binary array of when behaviors occur
    for behavior_index = 1:number_of_behaviors
        transition_indecies = allTracks_tri_ret(track_index).BehavioralTransition(:,1) == behavior_index;
        %transition into of
        transition_start_frames = allTracks_tri_ret(track_index).BehavioralTransition(transition_indecies,2);
        triggers(behavior_index,transition_start_frames) = true;
%                 %transition out of
%                 transition_end_frames = Tracks(track_index).BehavioralTransition(transition_indecies,3);
%                 triggers(behavior_index,transition_end_frames) = true;
    end
    allTracks_tri_ret(track_index).Behaviors = triggers(:,1:length(allTracks_tri_ret(track_index).LEDVoltages));
end

[TestLNPStats] = ValidateLNP(allTracks_tri_ret, folder_indecies, folders_tri_ret, LNPStats);
PlotValidateBehavioralMappingExperimentGroup(TestLNPStats, LNPStats, meanLEDPower, stdLEDPower, L, density, xx);

%% cut up tracks into 10 min sections and compare to LNP params
max_frame_number = 30*60*14;
number_of_sections = 3;
loadFileName = '16_09_20_embedding_ret_LNPFit_NLfix_12_behaviors_section_';
for section_index = 1:number_of_sections
    load([loadFileName, num2str(section_index), '.mat']);
    
    start_frame = (section_index-1)*max_frame_number/number_of_sections+1;
    end_frame = section_index*max_frame_number/number_of_sections;

    [section_Tracks, section_track_indecies] = FilterTracksByTime(allTracks_tri_ret,start_frame,end_frame);
    [TestLNPStats] =  ValidateLNP(section_Tracks,folder_indecies(section_track_indecies),folders_tri_ret,LNPStats);

    PlotValidateBehavioralMappingExperimentGroup(TestLNPStats, LNPStats, meanLEDPower, stdLEDPower, L, density, xx);
end

%% cut up tracks into uptick frames and downtick frames
%get what the triangle wave looks like
LEDVoltages = load([folders_tri_ret{1}, filesep, 'LEDVoltages.txt']);
second_deriv = [0, diff(diff(LEDVoltages)), 0];
uptick_starts = [1, find(second_deriv > 0.01)];
uptick_ends = [find(second_deriv < -0.01), length(LEDVoltages)];
all_uptick_tracks = [];
all_uptick_track_indecies = [];
for section_index = 1:length(uptick_starts)
    start_frame = uptick_starts(section_index)+1;
    end_frame = uptick_ends(section_index);

    [temp_tracks, temp_track_indecies] = FilterTracksByTime(allTracks_tri_ret,start_frame,end_frame);
    all_uptick_tracks = [all_uptick_tracks, temp_tracks];
    all_uptick_track_indecies = [all_uptick_track_indecies, temp_track_indecies];
end

downtick_starts = find(second_deriv < -0.01);
downtick_ends = [find(second_deriv > 0.01), length(LEDVoltages)];
all_downtick_tracks = [];
all_downtick_track_indecies = [];
for section_index = 1:length(uptick_starts)
    start_frame = downtick_starts(section_index)+1;
    end_frame = downtick_ends(section_index);

    [temp_tracks, temp_track_indecies] = FilterTracksByTime(allTracks_tri_ret,start_frame,end_frame);
    all_downtick_tracks = [all_downtick_tracks, temp_tracks];
    all_downtick_track_indecies = [all_downtick_track_indecies, temp_track_indecies];
end

uptick_behaviors = [all_uptick_tracks.Behaviors];
downtick_behaviors = [all_downtick_tracks.Behaviors];

uptick_behavioral_counts = sum(uptick_behaviors,2);
downtick_behavioral_counts = sum(downtick_behaviors,2);

uptick_behavioral_std = sqrt(uptick_behavioral_counts) ./ size(uptick_behaviors,2)*14*60;
downtick_behavioral_std = sqrt(downtick_behavioral_counts) ./ size(downtick_behaviors,2)*14*60;

uptick_behavioral_rates = uptick_behavioral_counts ./ size(uptick_behaviors,2)*14*60;
downtick_behavioral_rates = downtick_behavioral_counts ./ size(downtick_behaviors,2)*14*60;

figure
hold on
errorbar(uptick_behavioral_rates, uptick_behavioral_std, 'r*')
errorbar(downtick_behavioral_rates, downtick_behavioral_std, 'bo')
hold off
xlabel('Behavioral Region');
ylabel('Transition Rate (Behavior/Min)');
legend({'Increasing','Decreasing'});

% %separate by behaviors
% for behavior_index = 1:number_of_behaviors
%     figure
%     hold on
%     relevant_indecies = find(edges(:,2) == behavior_index);
%     errorbar(uptick_behavioral_rates(relevant_indecies), uptick_behavioral_std(relevant_indecies), 'r*')
%     errorbar(downtick_behavioral_rates(relevant_indecies), downtick_behavioral_std(relevant_indecies), 'bo')
%     xticklabelcells = {};
%     for edge_index = 1:length(relevant_indecies);
%         xticklabelcells{edge_index} = [num2str(edges(relevant_indecies(edge_index),1)) ' To ' num2str(edges(relevant_indecies(edge_index),2))];
%     end
%     xticklabelcells{edge_index+1} = '';
%     set(gca,'XTick',1:size(edges,1))
%     set(gca,'XTickLabel',xticklabelcells)
%     set(gca,'XTickLabelRotation',90)
% 
%     hold off 
%     xlabel('Behavioral Region');
%     ylabel('Transition Rate (Behavior/Min)');
%     legend({'Increasing','Decreasing'});
% 
% end
%% plot the LEDPower
fps = 14;
parameters = load_parameters();
LEDPower = LEDVoltages .* parameters.avgPower500 ./ 5;
plot(1/fps:1/fps:length(LEDVoltages)/fps, LEDPower)
xlabel('Time (s)')
ylabel('Power (uW/mm^2)')
%% plot embedding densities
PlotWatershed(vertcat(all_uptick_tracks(:).Embeddings));
figure
PlotWatershed(vertcat(all_downtick_tracks(:).Embeddings));

figure
PlotWatershedDifference(vertcat(all_uptick_tracks(:).Embeddings),vertcat(all_downtick_tracks(:).Embeddings));

%% plot bar graph comparison style uptick vs downtick behavioral rates for directional
from_region = 5;
to_region = 3;
edge_index = find(edges(:,1) == from_region & edges(:,2) == to_region);

X = 1:2;
Y = [uptick_behavioral_rates(edge_index), downtick_behavioral_rates(edge_index)];
E = [uptick_behavioral_std(edge_index), downtick_behavioral_std(edge_index)];
figure('Position', [400, 400, 700, 700])
ax = gca;
%ax.XTick = ;
%             ax.YTick = linspace(0.64,0.84,5);
ax.FontSize = 18;

hold on
% bar(1, Y(1),'k')
% bar(2, Y(2),'w')

errorbar(X(1),Y(1),E(1),'r.','linewidth',2,'markersize',40)
errorbar(X(2),Y(2),E(2),'b.','linewidth',2,'markersize',40)
plot(X,Y,'m-','linewidth',2)

%Width of the top and bottom lines of errorbar
xlength = 0.15;
colors = 'rb';
% Make horizontal lines with 'line'
for k = 1:length(X)
    x = [X(k) - xlength, X(k) + xlength];
    y_h = [Y(k) + E(k), Y(k) + E(k)];
    line(x, y_h,'color',colors(k),'linewidth',2);
    y_b = [Y(k) - E(k), Y(k) - E(k)];
    line(x, y_b,'color',colors(k),'linewidth',2);
end
y_limits = get(gca,'YLim');
set(gca,'YTick',linspace(y_limits(1),y_limits(2),NumTicks))
set(gca, 'XTick', [])
%% plot bar graph comparison style uptick vs downtick behavioral rates for nondirectional
region_index = 9;
X = 1:2;
Y = [uptick_behavioral_rates(region_index), downtick_behavioral_rates(region_index)];
E = [uptick_behavioral_std(region_index), downtick_behavioral_std(region_index)];
figure('Position', [400, 400, 700, 700])
ax = gca;
%ax.XTick = ;
%             ax.YTick = linspace(0.64,0.84,5);
ax.FontSize = 18;

hold on
% bar(1, Y(1),'k')
% bar(2, Y(2),'w')

errorbar(X(1),Y(1),E(1),'r.','linewidth',2,'markersize',40)
errorbar(X(2),Y(2),E(2),'b.','linewidth',2,'markersize',40)
plot(X,Y,'m-','linewidth',2)

% %plot the predicted rates
% plot(X(1),LNPStats(region_index).uptick_rate, 'r*')
% plot(X(2),LNPStats(region_index).downtick_rate, 'b*')

%Width of the top and bottom lines of errorbar
xlength = 0.15;
colors = 'rb';
% Make horizontal lines with 'line'
for k = 1:length(X)
    x = [X(k) - xlength, X(k) + xlength];
    y_h = [Y(k) + E(k), Y(k) + E(k)];
    line(x, y_h,'color',colors(k),'linewidth',2);
    y_b = [Y(k) - E(k), Y(k) - E(k)];
    line(x, y_b,'color',colors(k),'linewidth',2);
end
y_limits = get(gca,'YLim');
x_limits = get(gca,'XLim');

axis([x_limits,y_limits(1),y_limits(2)]);
axis([x_limits,1,1.35]);
y_limits = get(gca,'YLim');

set(gca,'YTick',linspace(y_limits(1),y_limits(2),NumTicks))
set(gca, 'XTick', [])
%% plot bar graph comparison style uptick vs downtick behavioral rates for behavioral ratios
numerator_region = 9;
denominator_region = 2;

X = 1:2;
Y = [uptick_behavioral_rates(numerator_region) ./ uptick_behavioral_rates(denominator_region), ...
    downtick_behavioral_rates(numerator_region) ./ downtick_behavioral_rates(denominator_region)];

E = [];
E(1) = sqrt((uptick_behavioral_std(numerator_region)./uptick_behavioral_rates(denominator_region))^2+(uptick_behavioral_rates(numerator_region)*uptick_behavioral_std(denominator_region)./(uptick_behavioral_rates(denominator_region)^2))^2);
E(2) = sqrt((downtick_behavioral_std(numerator_region)./downtick_behavioral_rates(denominator_region))^2+(downtick_behavioral_rates(numerator_region)*downtick_behavioral_std(denominator_region)./(downtick_behavioral_rates(denominator_region)^2))^2);
%E(2) = sqrt((sqrt(downtick_behavioral_counts(numerator_region)-1)./downtick_behavioral_counts(denominator_region))^2+(downtick_behavioral_counts(numerator_region)*sqrt(downtick_behavioral_counts(uptick_behavioral_std(numerator_region))-1)./(downtick_behavioral_counts(denominator_region)^2))^2);

% E(1) = sqrt((Y(1)^2)*((uptick_behavioral_std(numerator_region)./uptick_behavioral_rates(numerator_region))^2 + (uptick_behavioral_std(denominator_region)./uptick_behavioral_rates(denominator_region)))^2 - (2*uptick_behavioral_std(numerator_region)*uptick_behavioral_std(denominator_region)./uptick_behavioral_rates(numerator_region)./uptick_behavioral_rates(denominator_region)));
% E(2) = sqrt((Y(2)^2)*((downtick_behavioral_std(numerator_region)./downtick_behavioral_rates(numerator_region))^2 + (downtick_behavioral_std(denominator_region)./downtick_behavioral_rates(denominator_region)))^2 - (2*downtick_behavioral_std(numerator_region)*downtick_behavioral_std(denominator_region)./downtick_behavioral_rates(numerator_region)./downtick_behavioral_rates(denominator_region)));


figure('Position', [400, 400, 700, 700])
ax = gca;
%ax.XTick = ;
%             ax.YTick = linspace(0.64,0.84,5);
ax.FontSize = 18;

hold on
% bar(1, Y(1),'k')
% bar(2, Y(2),'w')

errorbar(X(1),Y(1),E(1),'r.','linewidth',2,'markersize',40)
errorbar(X(2),Y(2),E(2),'b.','linewidth',2,'markersize',40)
plot(X,Y,'m-','linewidth',2)

%Width of the top and bottom lines of errorbar
xlength = 0.15;
colors = 'rb';
% Make horizontal lines with 'line'
for k = 1:length(X)
    x = [X(k) - xlength, X(k) + xlength];
    y_h = [Y(k) + E(k), Y(k) + E(k)];
    line(x, y_h,'color',colors(k),'linewidth',2);
    y_b = [Y(k) - E(k), Y(k) - E(k)];
    line(x, y_b,'color',colors(k),'linewidth',2);
end

set(gca, 'XTick', [])

%% Predict the changes to behavioral rate wrt time for every behavior
% then take the average behavioral rate for the uptick and downtick
% regions
LEDVoltages = load([folders_tri_ret{1}, filesep, 'LEDVoltages.txt']);
parameters = load_parameters(folders_tri_ret{1});
LEDPowers = LEDVoltages ./ 5 .* parameters.avgPower500;

second_deriv = [0, diff(diff(LEDVoltages)), 0];
uptick_starts = [1, find(second_deriv > 0.01)];
uptick_ends = [find(second_deriv < -0.01), length(LEDVoltages)];
downtick_starts = find(second_deriv < -0.01);
downtick_ends = [find(second_deriv > 0.01), length(LEDVoltages)];

%find a section for uptick and downtick. the predictions are gonna be
%periodic anyways
uptick_start_frame = uptick_starts(2)+1;
uptick_end_frame = uptick_ends(2);
downtick_start_frame = downtick_starts(2)+1;
downtick_end_frame = downtick_ends(2);

for LNP_index = 1:length(LNPStats)
    predicted_triangle_rate = PredictLNP(LEDPowers,LNPStats(LNP_index).linear_kernel,LNPStats(LNP_index).non_linearity_fit);
    LNPStats(LNP_index).uptick_rate = mean(predicted_triangle_rate(uptick_start_frame:uptick_end_frame));
    LNPStats(LNP_index).downtick_rate = mean(predicted_triangle_rate(downtick_start_frame:downtick_end_frame));
end


