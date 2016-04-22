data_old = vertcat(oldSpectra{:});
data_new = vertcat(Spectra{:});

data_old = data_old(:);
data_new = data_new(:);

data_diff = find(data_new - data_old);