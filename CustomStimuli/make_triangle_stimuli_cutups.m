number_of_frames = 139;
%min_power = 0;
max_power = 18;
avg_power = max_power./2;

inc_to_dec = TrianglePulse(1,number_of_frames);
%scale
inc_to_dec = inc_to_dec ./ max(inc_to_dec) .* avg_power;
dec_to_inc = -inc_to_dec;
inc_to_dec = inc_to_dec + avg_power;
dec_to_inc = dec_to_inc + avg_power;

inc_only = 0:number_of_frames-1;
inc_only = inc_only ./ max(inc_only) .* max_power;
dec_only = fliplr(inc_only);

triangle_stimuli = [inc_to_dec;dec_to_inc;inc_only;dec_only];




[filename, pathname] = uiputfile('*.txt','Save Stimuli As');
dlmwrite(fullfile(pathname, filename), triangle_stimuli,'delimiter','\t');