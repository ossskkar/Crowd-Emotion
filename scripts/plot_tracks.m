% DESCRIPTION: Plot tracks of a given dataset

% Clean up
clear; close all; clc;
clc; disp('Step 4.1: Clean up'); 

% Load data
clc; disp('Step 4.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

% Plot background image
img = imread(config.imgFile);
imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
set(gca,'YDir','normal')

hold on

% For each track
for i = 1:length(data.trainSet{1}.tracks)

    % Get current track
    this_track = data.trainSet{1}.tracks{i};
    
    % Plot current track
    plot(this_track(:,2), this_track(:,3), 'LineWidth', 5);
    %plot(this_track(:,2), this_track(:,3),'.k', 'MarkerSize', 15);
    %plot(this_track(:,2), this_track(:,3),'.w', 'MarkerSize', 10);
    
end

hold off

% Hide Axis values
ax = gca;
%ax.Visible = 'off';

% Reduce white space when ploting a figure
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

