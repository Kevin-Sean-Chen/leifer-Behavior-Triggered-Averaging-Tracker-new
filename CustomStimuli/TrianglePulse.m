function [stimulus] = TrianglePulse(intensity_sum, duration)
%TrianglePulse generates a triangle pulse that lasts duration with a sum of
%intensity_sum

    stimulus_max = intensity_sum / duration * 2;
    stimulus = linspace(-stimulus_max, stimulus_max, duration+2);
    stimulus = abs(stimulus(2:end-1));
    stimulus = stimulus_max - stimulus;
end
