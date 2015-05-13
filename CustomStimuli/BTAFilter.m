function [stimulus, intensity_sum] = BTAFilter()
%BTAFilter generates a stimulus that looks like the linear filter derived
%from behavior triggered average experiment

    %load the linear filter file
    [filename,pathname,~] = uigetfile('*.mat','Load Linear Kernal');
    load(fullfile(pathname,filename))

    stimulus = filplr(linear_kernal - min(linear_kernal));
    intensity_sum = sum(stimulus);
end
