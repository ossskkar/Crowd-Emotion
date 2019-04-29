% DESCRIPTION: Plot Level of Service for one zone

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% Select dataset
set_i = 1;
%dataset = data.trainSet{set_i};
dataset = data.testSet{set_i};


% Time interval to plot
time.start = 100;
%time.end = length(unique(dataset.raw(:,1)));
time.end = 200;

% Zone to plot
zi = 20;
 
% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
hold on

% Create meshgrid for X and Y axes
[X, Y] = meshgrid(time.start:time.end, 1:25);

% Assign colormap
nv = [1 0 0]; % Negative valence denoted by red color
cv = [1 1 0]; % Neutral valence denoted by yellow color
pv = [0 1 0]; % Positive valence denoted by green color
scale = 20;
cm = [ linspace(nv(1), cv(1), scale) linspace(cv(1), pv(1), scale*0.3); ...
       linspace(nv(2), cv(2), scale) linspace(cv(2), pv(2), scale*0.3); ...
       linspace(nv(3), cv(3), scale) linspace(cv(3), pv(3), scale*0.3)]
colormap(cm.');

% Plot LOS of all zones as a surface
s = surf(X, Y, dataset.crowd_emotion_est_cum(time.start:time.end,:).');

% Assign labels in colorbar
c = colorbar;
c.Location = 'northoutside';
c.Limits = [0 1];
c.Ticks = [0 0.5 1];
c.TickLabels = {'               Negative', 'Neutral', 'Positive             '};
c.FontSize = 20

% Title and labels
%title('\fontsize{20}Level of Service for All Zones', 'FontWeight','normal');
xlabel('Time (Seconds)','FontSize', 20);
ylabel('Sub-regions','FontSize', 20);
axis([time.start time.end 1 25])

% Reduce white space when ploting a figure
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3);
ax_height = outerpos(4);
ax.Position = [0 0 ax_width ax_height];

hold off
