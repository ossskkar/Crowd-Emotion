% Clean up
clear; close all; clc;

% Load data
load ../data/sim_amb_nonpeak_dlow_wfast;

% Trajectory
z = data.tracks{22}(:,2:3).';

% Initialize Kalman Filter
KF = create_KF;

% Run Kalman Filter
x = run_KF(KF, z(:,1:100));

% Plot results
plot(z(1,:), z(2,:), '.')
hold on
plot(x(1,:), x(2,:), '.r')
hold off
