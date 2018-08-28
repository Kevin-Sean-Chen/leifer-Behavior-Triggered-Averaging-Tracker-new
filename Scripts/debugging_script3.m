    %predict the behavioral rates based on the preloaded LNP model
    for behavior_index = 8:8
        experiment_behavior_predictions(behavior_index,:) = PredictLNP(PWM_dutycycles, LNPStats(behavior_index).linear_kernel, LNPStats(behavior_index).non_linearity_fit);
    end