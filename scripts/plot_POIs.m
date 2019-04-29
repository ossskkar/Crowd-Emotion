% DESCRIPTION: Plot the points/boundaries and number of each POI

% Clean up 
close all; clear; clc;

% Load data
load('../data/config');
load(config.dataFile);

% Get gt groundtruth
gt = data.POI.groundtruth;

% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

% Plot background image to specific coordinates
img = imread(config.imgFile);
imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% For each attractor 
for a_idx = 1:data.POI.len

    % Plot attractor points
    %plot(gt{a_idx}.p(:,1), gt{a_idx}.p(:,2),'.');
    
    % Plot attractor boundary
    x = min(gt{a_idx}.p(gt{a_idx}.b,1));
    y = min(gt{a_idx}.p(gt{a_idx}.b,2));
    w = max(gt{a_idx}.p(gt{a_idx}.b,1)) - min(gt{a_idx}.p(gt{a_idx}.b,1));
    h = max(gt{a_idx}.p(gt{a_idx}.b,2)) - min(gt{a_idx}.p(gt{a_idx}.b,2));
    rectangle('Position', [x, y, w, h], ...
        'FaceColor', [1 1 0 0.4], ...
        'EdgeColor', [1 1 0 1])
    
    % Plot number of attractor
    text(mean(gt{a_idx}.p(:,1)),mean(gt{a_idx}.p(:,2)),num2str(a_idx),'FontSize',25);
    
end

% For each track
for i = 1:length(data.trainSet{1}.tracks)

    % Get current track
    this_track = data.trainSet{5}.tracks{i};
    
    % Plot current track
    plot(this_track(:,2), this_track(:,3), 'LineWidth', 5);
    plot(this_track(:,2), this_track(:,3),'.k', 'MarkerSize', 7);
    %plot(this_track(:,2), this_track(:,3),'.w', 'MarkerSize', 35);
    
end


% Hide Axis values
ax = gca;
ax.Visible = 'off';

% Reduce white space when ploting a figure
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3);
ax_height = outerpos(4);
ax.Position = [0 0 ax_width ax_height];

