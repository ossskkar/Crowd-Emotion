% DESCRIPTION: Plot agents' tracks along with their estimation produced
%              by Kalman Filter.

% Clean up
clear; close all; clc;

% Load data
load ../data/data;

% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

% Plot background image
img = imread('../images/cstation_cf.png');
imagesc([0 data.inf.frame_size(1)], [0 data.inf.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% For each track
for i = 1:10:length(data.tracks)

    % Get current track
    this_track = data.tracks{i};
    this_x = data.KF{i}.x;
    
    % Plot current track
    plot(this_track(:,2), this_track(:,3), 'b');
    
    % Plot estimation of current track
    plot(this_x(:,1), this_x(:,2), '.r');
    
end

hold off