% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% Select test set
set_i = 1;

% Select zone
zi = 1;

% Crowd state observation
obs.max_len = 60;
obs.start = 1;
obs.end = obs.start + obs.max_len - 1;
obs.y = data.testSet{set_i}.crowd_state(obs.start:obs.end,zi);

% Select initial time
ti = 1;
t = ti:(ti+obs.max_len)-1

% Get Gaussian model prediction
bmu = data.testSet{set_i}.crowd_m_bmu{ti,zi};
ypred = data.trainSet{bmu.mdl_idx}.LOS.ypred{zi};

hold on

plot(t, obs.y,'b','LineWidth', 2);
plot(t, ypred(bmu.start:bmu.end),'g', 'LineWidth', 2);
hold off

% Formating 
xlabel('Time (seconds)');

ylabel('Flow Rate (ped/min/m)');
%yticks([0.4 0.5 0.6 0.7 0.8]);

lgd = legend( 'Observation', 'Prediction');

axis([ti max(t) 0 max([max(obs.y) max(ypred(bmu.start:bmu.end))])+5])

set(gca,'fontsize',20)
box on

print('../figures/crowd_m_est_one_zone','-dpng');