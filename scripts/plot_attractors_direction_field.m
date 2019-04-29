% DESCRIPTION: Plot the points/boundaries and number of each attractor

% Clean up 
close all; clear; clc;

% Load data
load ../data/attractors;
load ../data/data;

% Attractor id
ai_gt = 10;
ai_es = 20;

% Mask for only one attractor
r = 20;
[mx, my] = meshgrid(1:data.inf.frame_size(1), 1:data.inf.frame_size(2));
hm_mask = (mx - attractors.estimated.centroids(ai_es,1)).^2 ...
        + (my - attractors.estimated.centroids(ai_es,2)).^2 <= r.^2;

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
im = imagesc(attractors.estimated.heatmap.*hm_mask);
im.AlphaData = 0.5;

% Mesh scale for direction field
m = 10;

% Plot scaled quiver
%for x = 1:m:500
%    for y = 1:m:220
%        quiver(x, y, attractors.groundtruth{ai_gt}.df_x(y,x), attractors.groundtruth{ai_gt}.df_y(y,x),8,'MaxHeadSize',100, 'Color','r');
%    end
%end

quiver(attractors.groundtruth{ai_gt}.df_x, attractors.groundtruth{ai_gt}.df_y);

% Plot attractor centroids
plot(attractors.estimated.centroids(ai_es,1), attractors.estimated.centroids(ai_es,2),'+k');

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
