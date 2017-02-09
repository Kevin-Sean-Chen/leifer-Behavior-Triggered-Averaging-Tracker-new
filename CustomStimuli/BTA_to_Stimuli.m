stimuli_of_interest = [8 9];
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
%plot(stimuli(2,:))

[filename, pathname] = uiputfile('*.txt','Save Stimuli As');
dlmwrite(fullfile(pathname, filename), stimuli,'delimiter','\t');
