%not used in paper

parameters = load_parameters();

fastWavelet_morlet_convolution_parallel([],parameters.minF,parameters.omega0,1/14);

longest_time_scale = (parameters.omega0 + sqrt(2+parameters.omega0^2))./(4*pi.*parameters.minF)