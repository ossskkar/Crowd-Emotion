% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

hold on

% results of proposed method
plot(data.results.tracks_m_est_accuracy_summary(:,2), ...
     data.results.tracks_m_est_accuracy_summary(:,3), ...
                     '-s','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 2, 'Color', 'g');

% results of method 1
res1.x = 0:5:50;
res1.y = ones(11,1)*0.48;
plot(res1.x, res1.y, '-s','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 2, 'Color', 'm');

% results of method 2
res2.x = 0:5:50;
res2.y = ones(11,1)*0.43;
plot(res2.x, res2.y, '-s','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 2, 'Color', 'b');

hold off

% Formating 
xlabel('Number of Observations');

ylabel('Accuracy');
yticks([0.4 0.5 0.6 0.7 0.8]);

lgd = legend( 'Proposed', 'Stationary Crowd [3]', 'MDA [4]');

axis([0 50 0.40 0.80])

set(gca,'fontsize',20)
box on

print('../figures/pedestrian_m_est_accuracy','-dpng');