% DESCRIPTION: Plot the points/boundaries and number of each attractor

% Clean up 
close all; clear; clc;

% Load data
load ../data/attractors;
load ../data/data;

% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

% Plot background image to specific coordinates
img = imread('../images/cstation_cf.png');
imagesc([0 data.inf.frame_size(1)], [0 data.inf.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% Plot heatmap
im = imagesc(attractors.estimated.heatmap);
im.AlphaData = 0.5;

% Plot attractors centroids
plot(attractors.estimated.centroids(:,1), attractors.estimated.centroids(:,2),'*r');

hold off

% Hide Axis values
ax = gca;
ax.Visible = 'off';

% Reduce white space when ploting a figure
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
