function [stimulus] = SquarePulse(intensity_sum, duration)
%SquarePulse generates a square pulse that lasts duration with a sum of
%intensity_sum
    stimulus = zeros(1,duration);
    stimulus(:) = intensity_sum / duration;
end
