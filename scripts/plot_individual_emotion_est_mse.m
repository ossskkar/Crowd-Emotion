% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

hold on

% results of proposed method
plot(data.results.tracks_emotion_mse_summary(:,2), ...
     data.results.tracks_emotion_mse_summary(:,3), ...
                     '-s','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 2, 'Color', 'r');

hold off

% Formating 
xlabel('Number of Observations');

ylabel('MSE');
yticks([0.014 0.015 0.016 0.017]);

axis([0 50 1.4e-2 1.7e-2])

set(gca,'fontsize',20)
box on
print('../figures/pedestrian_emotion_est_mse','-dpng');