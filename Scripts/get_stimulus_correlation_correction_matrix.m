%not used in paper

iterations = 10000000;
par_for_iterations = 100;
for_iterations = iterations/par_for_iterations;
BTA_length = 281;

par_for_covariance_matrix = zeros(BTA_length,BTA_length,par_for_iterations);

parfor par_for_iteration_index = 1:par_for_iterations
    covariance_matrix = zeros(BTA_length);
    for for_iteration_index = 1:for_iterations
       powers = GuassianCorrelationTime();
       X = makeStimRows(powers, BTA_length);
       covariance_matrix = covariance_matrix + (transpose(X)*X);
    end
    covariance_matrix = covariance_matrix./for_iterations;
    par_for_covariance_matrix(:,:,par_for_iteration_index) = covariance_matrix;
    par_for_iteration_index
end

covariance_matrix = mean(par_for_covariance_matrix,3);

inv_covariance_matrix = inv(covariance_matrix);

figure
imagesc(covariance_matrix)
colorbar

figure
max_value = max(abs(inv_covariance_matrix(:)))*0.01;
imagesc(inv_covariance_matrix)
caxis([-max_value max_value]);
colormap('redblue')
colorbar
stim_correction_filter = inv_covariance_matrix(141,:);
plot(stim_correction_filter)


%we only want a range of diagonal elements
correlation_distance = 281;
corrected_inv_covariance_matrix = zeros(size(inv_covariance_matrix));
for distance_index = -correlation_distance:correlation_distance
    values_for_diag = diag(inv_covariance_matrix,distance_index);
    mean_value_for_diag = mean(values_for_diag);
    corrected_inv_covariance_matrix = corrected_inv_covariance_matrix + diag(repmat(mean_value_for_diag,1,length(values_for_diag)),distance_index);
end
figure
max_value = max(abs(corrected_inv_covariance_matrix(:)))*0.0001;
imagesc(corrected_inv_covariance_matrix)
caxis([-max_value max_value]);
colormap('redblue')
colorbar



BTA = LNPStats_nondirectional_ret(1).linear_kernel;
%whitened_BTA = corrected_inv_covariance_matrix*BTA';
whitened_BTA = padded_conv(stim_correction_filter,BTA);
plot(whitened_BTA)
hold on
plot(BTA)
% 
% load('C:\Users\mochil\Dropbox\LeiferShaevitz\Papers\mec-4\17_02_24_LNPStats_directional_and_nondirectional.mat')
% BTA = LNPStats_nondirectional_ret(1).BTA;
% whitenedBTA = covariance_matrix \ BTA';
% plot(whitenedBTA);