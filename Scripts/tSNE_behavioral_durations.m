%not used in paper

fps = 14;
rows_per_page = 2;
column_number = 3;

Behaviors = cell(size(Embeddings));
all_behavioral_sequence = [];
all_behavioral_duration = [];
for track_index = 1:length(Behaviors)
    behavioral_annotation = behavioral_space_to_behavior(Embeddings{track_index}, L, xx);
    behavioral_transitions = [0, diff(double(behavioral_annotation))];
    indecies_of_transitions = [1, find(abs(behavioral_transitions))];
    behavioral_sequence = behavioral_annotation(indecies_of_transitions);
    behavioral_duration = [diff(indecies_of_transitions), length(behavioral_annotation)-indecies_of_transitions(end)];
    
    all_behavioral_sequence = [all_behavioral_sequence, behavioral_sequence];
    all_behavioral_duration = [all_behavioral_duration, behavioral_duration];
    Behaviors{track_index} = behavioral_annotation;
end

% %plot histogram of durations for all the behaviors
% edges = 10.^(-2:0.01:3); 
% h = histc(all_behavioral_duration ./ fps, edges);
% centers = sqrt(edges(1:end-1).*edges(2:end));
% figure
% bar(h)
% ax = gca;
% %set(ax,'YScale','log');
% xlim(ax, [0 length(centers)-1])
% ax.XTickLabel = round(centers(round(ax.XTick)+1),1, 'significant');
% xlabel('Duration (s)') % x-axis label
% ylabel('Count') % y-axis label

%plot histogram of durations for each behavior independently
figure('units','normalized','outerposition',[0 0 1 1])
plot_index = 1;
for behavior_index = 37:39%double(max(L(:)))
    %find all occurances of the behavior and look up their duration
    behavioral_durations = all_behavioral_duration(all_behavioral_sequence == behavior_index);
    
%    scrollsubplot(rows_per_page, column_number, behavior_index);
    subplot(rows_per_page, column_number, plot_index) %behavior_index);
    edges = 10.^(-2:0.01:3); 
    h = histc(behavioral_durations ./ fps, edges);
    centers = sqrt(edges(1:end-1).*edges(2:end));
    bar(h)
    ax = gca;
    set(ax,'YScale','log');
    xlim(ax, [0 length(centers)-1])
    ax.XTickLabel = round(centers(round(ax.XTick)+1),1, 'significant');
    xlabel('Duration (s)') % x-axis label
    ylabel(['Behavior ', num2str(behavior_index) ,' Count']) % y-axis label
    plot_index = plot_index + 1;
end