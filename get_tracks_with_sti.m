function [sti_tracks,TAPonly_tracks,LEDonly_tracks]=get_tracks_with_sti(Tracks,time_before,time_after)
% extract tracks that around a tap/LED sti 
% align tracks frames with sti to be frame=0
sti_tracks=struct([]);
TAPonly_tracks=struct([]);
LEDonly_tracks=struct([]);
fps=14;
n_track=length(Tracks);
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
    Tap_span=Tap_on;
 i
    sti_frames=current_track.Frames(LED_on&Tap_on);
   
    for tap=sti_frames
        frame0=current_track.Frames(1)-1;
        % Tap occur on the 29th frame of LED_on
        both_on(max(tap-28-frame0,1):min(tap+27-frame0,track_len))=1;
    end
    
    LED_only_frames=current_track.Frames(LED_on&(~both_on));
    Tap_only_frames=current_track.Frames(Tap_on&(~LED_on));
%         LED_only_trial_frame=[];
%     for this_frame = LED_only_frames
%         if LED_on(this_frame-28) &&LED_on(this_frame+27)
%             LED_only_trial_frame=[LED_only_trial_frame,this_frame];
%         end
%     end
    %
    for trial_frame = sti_frames
        start_frame=trial_frame-(fps*time_before-1);
        end_frame=trial_frame+fps*time_after;
        this_track= FilterTracksByTime(current_track, start_frame, end_frame);
        this_track.Frames=this_track.Frames-trial_frame;
        sti_tracks=[sti_tracks, this_track];
    end
    
    for trial_frame = Tap_only_frames
        start_frame=trial_frame-(fps*time_before-1);
        end_frame=trial_frame+fps*time_after;
        this_track= FilterTracksByTime(current_track, start_frame, end_frame);
        this_track.Frames=this_track.Frames-trial_frame;
        TAPonly_tracks=[TAPonly_tracks, this_track];
    end
    last_frame=0;
    for trial_frame = LED_only_frames
        if abs(last_frame-trial_frame)>56
            start_frame=trial_frame-(fps*time_before-1);
            end_frame=trial_frame+fps*time_after;
            this_track= FilterTracksByTime(current_track, start_frame, end_frame);
            this_track.Frames=this_track.Frames-trial_frame-28;
            LEDonly_tracks=[LEDonly_tracks, this_track];
            last_frame=trial_frame;
        end
    end
    
end
end
