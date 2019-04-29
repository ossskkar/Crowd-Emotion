
clear; close all; clc; 

% Load simulation data
load '../data/sim_amb_nonpeak_wslow2';
sim = data;

% Adjustment of timelines to fit curves
adjust = 30;

figure;
suptitle('Fundamental Diagram')
% Density Plot
subplot(3,1,1);
plot(sim.density(:,1), sim.density(:,2));
%axis([0 60 0 0.0012]);
legend('Density');
ylabel('Density');

% Speed Plot
%subplot(3,1,2);
%subplot(3,1,1);
%plot(data.av(:,1)./25,data.av(:,2)); % vx

%subplot(3,1,2);
%plot(data.av(:,1)./25,data.av(:,3)); %vy

%subplot(3,1,3);
%plot(sim.avg_speed(:,1), sim.avg_speed(:,4)); %v
%axis([0 60 10 20]);
%legend('Simulation');
%ylabel('Speed');

% Similarity Index
%subplot(3,1,3);
%plot(sim.sim_index(:,1), sim.sim_index(:,2));
%axis([0 60 0.4 0.6]);
%legend('Simulation');
%ylabel('Similarity Index');


% Plot crowds
%{
figure
subplot(1,2,1)
scatter(data.raw(:,3), data.raw(:,4))
axis([0 700 -460 -20]);
pbaspect([1 1 1])

subplot(1,2,2)
scatter(-sim.raw(:,3), sim.raw(:,4))
axis([-700 0 75 510]);
pbaspect([1 1 1])
%}


