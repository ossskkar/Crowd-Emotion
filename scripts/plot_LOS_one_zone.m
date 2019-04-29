% DESCRIPTION: Plot Level of Service for one zone

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% Select dataset
dataset = data.trainSet{1};

% Select a zone
zi = 1;

% Select data range
range = [3000 4039];
%range = [1 length(dataset.crowd_state(:,zi))];

% Get data 
t = (range(1):range(2)).';
y = dataset.crowd_state(range(1):range(2),zi);
ypred = dataset.LOS.ypred{zi}(range(1):range(2));

% Open figure in fullscreen mode
close all;
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);
hold on

% For each LOS
for li = 1:data.LOS.len
    % Display background color rectangle for LOS li
    %rectangle('Position', [range(1) data.LOS.limits{li}(1) range(2) data.LOS.limits{li}(2)-data.LOS.limits{li}(1)], ...
    %          'FaceColor', [data.LOS.color{li} 0.4]);
end

% Display original data 
plot(t,y,'--*','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 2, 'Color', 'b');
plot(t,ypred,'-','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 3, 'Color', 'g');

% Title and labels
title(['\fontsize{20}Level of Service for Zone #' num2str(zi)], 'FontWeight','normal');
xlabel('Time (Seconds)');
ylabel('Pedestrian Volume (pedestrian / m / min)');

% Plot axes
axis([range(1) range(2) 0 max([max(y) max(ypred)])]);

hold off
