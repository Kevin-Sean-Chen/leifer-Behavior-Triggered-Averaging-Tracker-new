function [sti_tracks,TAPonly_tracks,LEDonly_tracks]=get_tracks_with_sti(Tracks,time_before,time_after)
% extract tracks that around a tap/LED sti 
sti_tracks=struct([]);
TAPonly_tracks=struct([]);
LEDonly_tracks=struct([]);
fps=14;
n_track=length(Tracks);
LED_on_duration=56;
hold_before_tap=28;
LED_after_tap=LED_on_duration-hold_before_tap-1;
if nargin<2
    time_before=10;
    time_after=10;
end
for i=1:n_track
    current_track=Tracks(i);
    track_len=length(current_track.Frames);
    LED_on=current_track.LEDVoltages>0;
    Tap_on=current_track.TapVoltages>0;    
    both_on=LED_on&Tap_on;
    
    sti_frames=current_track.Frames(both_on);  
    for tap=sti_frames
        frame0=current_track.Frames(1)-1;
        % Tap occur on the 29th frame of LED_on
        both_on(max(tap-hold_before_tap-frame0,1):min(tap+LED_after_tap-frame0,track_len))=1;
        % Make the binary 1 for the whole duration when LED is on.
    end
    
    LED_only_frames=current_track.Frames(LED_on&(~both_on));
    Tap_only_frames=current_track.Frames(Tap_on&(~LED_on));
    
    for trial_frame = sti_frames
        start_frame=trial_frame-(fps*time_before);
        end_frame=trial_frame+fps*time_after;
        this_track= FilterTracksByTime(current_track, start_frame, end_frame);
        % apply this if align tap to be frame=0
        %this_track.Frames=this_track.Frames-trial_frame;
        sti_tracks=[sti_tracks, this_track];
    end
    
    for trial_frame = Tap_only_frames
        start_frame=trial_frame-(fps*time_before);
        end_frame=trial_frame+fps*time_after;
        this_track= FilterTracksByTime(current_track, start_frame, end_frame);
        %this_track.Frames=this_track.Frames-trial_frame;
        TAPonly_tracks=[TAPonly_tracks, this_track];
    end
    last_frame=0;
    for trial_frame = LED_only_frames
        if abs(last_frame-trial_frame)>LED_on_duration
            start_frame=trial_frame-(fps*time_before);
            end_frame=trial_frame+fps*time_after;
            this_track= FilterTracksByTime(current_track, start_frame, end_frame);
            %this_track.Frames=this_track.Frames-trial_frame-28;
            LEDonly_tracks=[LEDonly_tracks, this_track];
            last_frame=trial_frame;
        end
    end
    
end
end
