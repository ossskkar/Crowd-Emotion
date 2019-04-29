% Clean up
disp('Cleaning up');
clear; close all; clc;

% Load data
disp('Loading data');
load ../data/sim_amb_nonpeak_dlow_wfast;

%For each track
for ai = 1:length(data.tracks)
    
    display(strcat('Processing track #', num2str(ai)));
    
    % Initialize Kalman Filter model
    data.KF{ai}.model = create_KF;
    
    % Compute state vector x
    data.KF{ai}.x = run_KF(data.KF{ai}.model, data.tracks{ai}(:,2:3).').';
    
end

% Save data
disp('Saving data');
save ../data/data data;

disp('Done!');
 