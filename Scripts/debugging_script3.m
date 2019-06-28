
for condition_index = 1:length(conditions)
    if strcmp(conditions{condition_index},'tap')
        critical_frames = tap_frames;
    elseif strcmp(conditions{condition_index},'control')
        critical_frames = control_frames;
    end

    track_count_that_end_on_frame = zeros(1,time_window_before+time_window_after+1);
    velocities_before = [];
    velocities_after = [];

    for critical_frame_index = 1:length(critical_frames)
        %for every time a stimulus is delivered, look through tracks with the
        %relevant window
        Tracks = FilterTracksByTime(allTracks, critical_frames(critical_frame_index)-time_window_before-1, critical_frames(critical_frame_index)+time_window_after, true);
        for track_index = 1:length(Tracks)
            mean_velocity_before = mean(Tracks(track_index).Velocity(1:time_window_before));
            mean_velocity_after = mean(Tracks(track_index).Velocity(time_window_before+2:end));
            velocities_before = [velocities_before, mean_velocity_before];
            velocities_after = [velocities_after, mean_velocity_after];
        end

    end
    
    %2D velocity histogram
    figure
    hold on
    histogram2(velocities_after,velocities_before,edges,edges,'DisplayStyle','tile','ShowEmptyBins','off', 'Normalization', 'probability')
    yL = get(gca,'YLim');
    xL = get(gca,'XLim');
    line(xL,[0 0],'Color','r','linewidth',2);
    line([0 0],yL,'Color','r','linewidth',2);
    line([0 xL(2)],[0, yL(2)],'Color','r','linewidth',2);
    axis square;
    colorbar
    xlabel('Velocity After Tap (mm/s)')
    ylabel('Velocity Before Tap (mm/s)')
    title(conditions{condition_index})
    
    %delta V based pie charts
    
    %exclude when velocity is < 0 before
    excluded_indecies_because_animal_was_reversing = velocities_before < 0;
    velocities_before(excluded_indecies_because_animal_was_reversing) = [];
    velocities_after(excluded_indecies_because_animal_was_reversing) = [];
    reverse_before_tap_count = sum(excluded_indecies_because_animal_was_reversing);
    
    excluded_indecies_because_animal_reversed_after_tap = velocities_after < 0;
    velocities_before(excluded_indecies_because_animal_reversed_after_tap) = [];
    velocities_after(excluded_indecies_because_animal_reversed_after_tap) = [];
    reverse_after_tap_count = sum(excluded_indecies_because_animal_reversed_after_tap);
    
    delta_velocity = velocities_after - velocities_before;
    
    slowdown_count = sum(delta_velocity < -thresh_velocity);
    speedup_count = sum(delta_velocity > thresh_velocity);
    same_count = length(delta_velocity) - slowdown_count - speedup_count;
    
    pie_labels = {'Reverse', 'Same', 'Speed Up', 'Slow Down'};
    figure
    pie([reverse_after_tap_count, same_count, speedup_count, slowdown_count], pie_labels);
    title(conditions{condition_index})
end
