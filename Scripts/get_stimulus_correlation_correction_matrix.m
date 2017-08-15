iterations = 10000;
BTA_length = 281;

covariance_matrix = zeros(BTA_length);

for iteration_index = 1:iterations
   powers = GuassianCorrelationTime();
   X = makeStimRows(powers, BTA_length);
   covariance_matrix = covariance_matrix + ((transpose(X)*X)./iterations);
end

inv_covariance_matrix = inv(covariance_matrix);

figure
imagesc(covariance_matrix)
colorbar

figure
max_value = max(abs(inv_covariance_matrix(:)));
imagesc(inv_covariance_matrix)
colormap('redblue')
