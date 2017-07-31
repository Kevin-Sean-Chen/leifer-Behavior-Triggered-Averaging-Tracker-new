% %loop through the behaviors and get the whitened sta for each
X = X-9;

nThi = size(X,1);
ntfilt = 281;
% 
% % Set up grid of lambda values (ridge parameters)
lamvals = 2.^(1:46); % it's common to use a log-spaced set of values
nlam = length(lamvals);
% 
% Divide data into "training" and "test" sets for cross-validation

trainfrac = .8;  % fraction of data to use for training
ntrain = ceil(nThi*trainfrac);  % number of training samples
ntest = nThi-ntrain; % number of test samples
iitest = 1:ntest; % time indices for test
iitrain = ntest+1:nThi;   % time indices for training
Xtrain = X(iitrain,:); % training stimulus
Xtest = X(iitest,:); % test stimulus
clear X
% Xtrain = [ones(ntrain,1),Xtrain];
% Xtest = [ones(ntest,1),Xtest];


for behavior_index = 1:1
    % Allocate space for train and test errors
    msetrain = zeros(nlam,1);  % training error
    msetest = zeros(nlam,1);   % test error
    w_ridge = zeros(ntfilt,nlam); % filters for each lambda

    spstrain = Y(iitrain,behavior_index);
    spstest =  Y(iitest,behavior_index);

    % Precompute some quantities (X'X and X'*y) for training and test data
    XXtr = Xtrain'*Xtrain;
    XYtr = Xtrain'*spstrain;  % spike-triggered average, training data
    Imat = eye(ntfilt); % identity matrix of size of filter + const
    %Imat(1,1) = 0; % don't apply penalty to constant coeff
    
    figure; hold on;
    for jj = 1:nlam
        % Compute ridge regression estimate
        w = (XXtr+lamvals(jj)*Imat) \ XYtr; 

        % Compute MSE
        msetrain(jj) = (mean((spstrain-Xtrain*w).^2)); % training error
        msetest(jj) = (mean((spstest-Xtest*w).^2)); % test error

        % store the filter
        w_ridge(:,jj) = w;

        % plot it
        plot(w);
        title(['ridge estimate: lambda = ', num2str(lamvals(jj))]);
        xlabel('time before spike (s)'); drawnow;
    end
    hold off;

%     figure
%     semilogx(lamvals,msetrain)
%     xlabel('lambda');
%     ylabel('MSE on training set');
%     
%     figure
%     semilogx(lamvals,msetest)
%     xlabel('lambda');
%     ylabel('MSE on testing set');

%     nsp = sum(Y(:,behavior_index)); %number of spikes
%     sta = (X'*Y(:,behavior_index))/nsp;
%     wsta = (X'*X)\sta*nsp; %whiten the STA
    %establish training and testing datasets
    
end
% figure
% plot(sta)
% figure
% plot(wsta)