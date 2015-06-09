% function [K_LNP, K_Shuffle] = CrossValidation()
%CrossValidation compares the predicted reversal rate with a null model
%   Detailed explanation goes here
    fps = 14;
    allTracks = [];
    trial_number = 2500;
    dt = 1/(fps*60);
    
    [filename,pathname] = uigetfile('*.mat','Select Experiment Group');
    
    if isequal(filename,0) || isequal(pathname,0)
        %cancel
       return
    else
        openFileName = fullfile(pathname,filename);
        if exist(openFileName, 'file')
          % File exists.  Load the folders
          load(openFileName)
          folders = {Experiments(1:end-1).Folder};
        end
    end

    %load the tracks
    for folder_index = 1:length(folders)
        folder_name = folders{folder_index};
        cd(folder_name) %open the directory of image sequence
        load('tracks.mat')
        if length(allTracks) == 0
            allTracks = Tracks;
        else
            allTracks = [allTracks, Tracks];
        end
    end
    
    % Get binary array of when certain behaviors start and the predicted
    % behavioral rate
    for track_index = 1:length(allTracks)
        pirouettes = allTracks(track_index).Pirouettes;
        behaviors = zeros(1, length(allTracks(track_index).LEDVoltages)); %a binary array of when behaviors occur
        for pirouette_index = 1:size(pirouettes,1)
            pirouetteStart = pirouettes(pirouette_index,1);
            behaviors(pirouetteStart) = 1;
        end
        allTracks(track_index).Behaviors = logical(behaviors);
    end
    
    LNPScore = zeros(1, trial_number);
    ShuffleScore = zeros(1, trial_number);
    parfor trial_index = 1:trial_number
        %take half the tracks and use them to fit the model while use the other
        %half to cross validate
        PermutatedTracks = randperm(length(allTracks));
        fitTracks = allTracks(PermutatedTracks(1:floor(length(allTracks)/2)));
        validationTracks = allTracks(PermutatedTracks(floor(length(allTracks)/2)+1:end));

        %fit the LNP
        [linear_kernel, non_linearity_fit, ~, ~, ~, ~, ~, ~] = FitLNP(fitTracks);

        exp_fit_a = non_linearity_fit.a;
        exp_fit_b = non_linearity_fit.b;

        %calculate the predicted rate for each validation track
        for validation_track_index = 1:length(validationTracks)
            validationTracks(validation_track_index).PredictedRate = PredictLNP(validationTracks(validation_track_index).LEDVoltages, linear_kernel, exp_fit_a, exp_fit_b);
        end
        Behaviors = double(~[validationTracks.Behaviors]);
        %Behaviors(Behaviors == 0) = -1;
        PredictedRate = [validationTracks.PredictedRate];
        rdt = PredictedRate.*dt;
        PredictedProbability = rdt.*exp(-rdt);
        %ShuffledBehaviors = Behaviors(randperm(length(Behaviors)));
        
        LNPScore(trial_index) = dot(Behaviors, PredictedProbability)/norm(Behaviors)/norm(PredictedProbability);
        %K_Shuffle(trial_index) = dot(ShuffledBehaviors, PredictedRate)/norm(ShuffledBehaviors)/norm(PredictedRate);
    end
    
%     figure
%     hist(LNPScore)
    
    parfor trial_index = 1:trial_number
        %take half the tracks and use them to fit the model while use the other
        %half to cross validate
        PermutatedTracks = randperm(length(allTracks));
        fitTracks = allTracks(PermutatedTracks(1:floor(length(allTracks)/2)));
        validationTracks = allTracks(PermutatedTracks(floor(length(allTracks)/2)+1:end));

        %fit the LNP
        [linear_kernel, non_linearity_fit, ~, ~, ~, ~, ~, ~] = FitLNP(fitTracks);

        exp_fit_a = non_linearity_fit.a;
        exp_fit_b = non_linearity_fit.b;

        %calculate the predicted rate for each validation track
        for validation_track_index = 1:length(validationTracks)
            validationTracks(validation_track_index).PredictedRate = PredictLNP(validationTracks(validation_track_index).LEDVoltages, linear_kernel, exp_fit_a, exp_fit_b);
        end
        Behaviors = double(~[validationTracks.Behaviors]);
        %Behaviors(Behaviors == 0) = -1;
        PredictedRate = [validationTracks.PredictedRate];
        rdt = PredictedRate.*dt;
        PredictedProbability = rdt.*exp(rdt);
        ShuffledBehaviors = Behaviors(randperm(length(Behaviors)));
        
        %K_LNP(trial_index) = dot(Behaviors, PredictedRate)/norm(Behaviors)/norm(PredictedRate);
        ShuffleScore(trial_index) = dot(ShuffledBehaviors, PredictedProbability)/norm(ShuffledBehaviors)/norm(PredictedProbability);
    end
%     figure
%     hist(ShuffleScore)
    
    p = ranksum(LNPScore,ShuffleScore, 'tail', 'right')
    
    edges = linspace(min([LNPScore, ShuffleScore]), max([LNPScore, ShuffleScore]),30);
    
    figure
    hist(LNPScore,edges)
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w','facealpha',0.75)
    hold on;
    hist(ShuffleScore,edges)
    h1 = findobj(gca,'Type','patch');
    set(h1,'facealpha',0.75);
    xlabel('Scores')
    ylabel('Count')
    legend('show')
    title(['Wilcoxon Rank Sum p = ', num2str(p)])
    % end