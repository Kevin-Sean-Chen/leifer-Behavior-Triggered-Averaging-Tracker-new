

stimuli_of_interest = find([LNPStats.BTA_percentile] > 0.99);
avg_power = meanLEDPower;
max_power = avg_power*2;
stimuli = vertcat(LNPStats(stimuli_of_interest).BTA);
stimuli = stimuli-avg_power;

%normalize each stimulus so that we get good coverage
for stimulus_index = 1:size(stimuli,1)
    stimulus_max = max(abs(stimuli(stimulus_index,:)));
    scale = avg_power ./ stimulus_max;
    stimuli(stimulus_index,:) = scale .* stimuli(stimulus_index,:);
end

stimuli = stimuli+avg_power;
figure
hold on
for stimulus_index = 1:size(stimuli,1)
    plot(stimuli(stimulus_index,:))
end


[filename, pathname] = uiputfile('*.txt','Save Stimuli As');
dlmwrite(fullfile(pathname, filename), stimuli,'delimiter','\t');
