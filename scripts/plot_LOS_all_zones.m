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
colormap(data.LOS.colormap);

% Plot LOS of all zones as a surface
s = surf(X, Y, dataset.crowd_state(time.start:time.end,:).');

% Assign labels in colorbar
c = colorbar;
c.TickLabels = {'', '', 'A', '','B', '', 'C','D','E', 'F'};

% Title and labels
%title('\fontsize{20}Level of Service for All Zones', 'FontWeight','normal');
xlabel('Time (Seconds)','FontSize', 20);
ylabel('Sub-regions','FontSize', 20);
axis([time.start time.end 1 25])

hold off
