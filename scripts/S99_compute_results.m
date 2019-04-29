
% RESUTLS #1: INDIVIDUAL MOTIVATION ESTIMATION FOR ALL TEST SETS AND
%             DIFFERENT OBSERVATION WINDOW SIZES

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% Initialize results variables
data.results.tracks_m_est = {};
data.results.tracks_m_est_accuracy = {};
data.results.tracks_m_est_accuracy_summary = [];

data.results.tracks_emotion_est = {};
data.results.tracks_emotion_mse = {};
data.results.tracks_emotion_mse_summary = [];

save(config.dataFile, 'data');

% For each config.sw_size
for i = 0:5:50

    % Update status
    disp(strcat("Estimating pedestrian motivation with theta=", num2str(i)));

    % Update window size
    load('../data/config');
    config.sw_size = i;
    save('../data/config','config');
    
    % Compute individual motivation
    S12_estimate_individual_motivation;

    % Compute individual emotions
    S13_estimate_individual_emotions;
    
    % Load data
    load('../data/config');
    load(config.dataFile);

    % Update status
    disp("Parse Results");
    
    % For each training/test set
    for set_i = 1:length(data.testSet)
    
        % Get current number of results
        len = length(data.results.tracks_m_est_accuracy);
        
        % Add new results of motivation estimation
        data.results.tracks_m_est{len+1} = data.testSet{set_i}.tracks_m_est;
        
        % Add new results of motivation estimation accuracy
        data.results.tracks_m_est_accuracy{len+1} = data.testSet{set_i}.tracks_m_est_accuracy;
        
        % Compute summary of motivation estimation accuracy for different
        % values of sliding window size
        data.results.tracks_m_est_accuracy_summary = [data.results.tracks_m_est_accuracy_summary; ...
            [set_i, config.sw_size, mean(data.testSet{set_i}.tracks_m_est_accuracy)]];
        
        % Add new results of emotion estimation
        data.results.tracks_emotion_est{len+1} = data.testSet{set_i}.tracks_emotion_est;
        
        % Add new results of motivation estimation mse
        data.results.tracks_emotion_mse{len+1} = data.testSet{set_i}.tracks_emotion_mse;
        
        % Use this to remove results with 'nan' value
        mse_summary = data.testSet{set_i}.tracks_emotion_mse;
        mse_summary(isnan(mse_summary)) = [];
        
        % Compute summary of emotion estimation mse for different
        % values of sliding window size
        data.results.tracks_emotion_mse_summary = [data.results.tracks_emotion_mse_summary; ...
            [set_i, config.sw_size, mean(mse_summary)]]; 
    end
    
    % Save data
    save(config.dataFile, 'data');
end

% Clean on exit
clear; close all; clc;
disp('RESULTS ARE READY!')

