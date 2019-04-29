% Clean up
disp('Cleaning up');
clear; close all; clc;

% Parameters
attractors_file = 'attractors_cstation_cvpr2015';
data_file = 'cstation_cvpr2015_eval_half_no_sw.mat';
img_file = 'cstation_cvpr2015.jpg';

% Load data
disp('Loading data');
load(strcat('../data/',attractors_file));
load(strcat('../data/',data_file));

% Get track data
ti = 1;
[ti_len, ~] = size(data.tracks{ti});
ti_data = data.tracks{ti}(:,2:3);

% Generate prototype tracks for new starting point y0
proto_tracks = get_proto_tracks(ti_data(1,:),attractors.groundtruth);

% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

% Plot background image to specific coordinates
img = imread(strcat('../images/',img_file));
imagesc([0 data.inf.frame_size(1)], [0 data.inf.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% For each attractor 
for ai = 1:length(attractors.groundtruth)

    % Plot attractor points
    plot(attractors.groundtruth{ai}.p(:,1), attractors.groundtruth{ai}.p(:,2),'.y');
    
    % Plot attractor boundary
    plot(attractors.groundtruth{ai}.p(attractors.groundtruth{ai}.b,1), attractors.groundtruth{ai}.p(attractors.groundtruth{ai}.b,2),'k');
    
    % Plot number of attractor
    text(mean(attractors.groundtruth{ai}.p(:,1)),mean(attractors.groundtruth{ai}.p(:,2)),num2str(ai),'FontSize',25);
    
    % Plot proto track
    plot(proto_tracks{ai}(:,1), proto_tracks{ai}(:,2),'*y');
    
end

% Plot direction field of attractor ai
%ai = 10;
%quiver(attractors.groundtruth{ai}.df_x, attractors.groundtruth{ai}.df_y)

% Plot track ti
plot(data.tracks{ti}(:,2), data.tracks{ti}(:,3), 'g');
plot(data.tracks{ti}(:,2), data.tracks{ti}(:,3), '*g');


% Plot initial point 
scatter(data.tracks{ti}(1,2), data.tracks{ti}(1,3), 100,...
    'filled', 'MarkerEdgeColor', [0 0 0],...
    'MarkerFaceColor', [0 1 0]);

% Plot final point 
scatter(data.tracks{ti}(ti_len,2), data.tracks{ti}(ti_len,3), 100,...
    'filled', 'MarkerEdgeColor', [0 0 0],...
    'MarkerFaceColor', [1 0 0]);

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


