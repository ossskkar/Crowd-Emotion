% DESCRIPTION: Plot Level of Service for one zone

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% Select dataset
set_i = 1;
dataset = data.testSet{set_i};

% Select a zone
zi = 4;

% Select data range
t_start = 1200;
t_end = t_start + config.LOS_intervalSize -1;
range = [t_start t_end];
%range = [1 length(dataset.crowd_state(:,zi))];

% Get data 
t = (range(1):range(2)).';
y = dataset.crowd_state(range(1):range(2),zi);

% Get best matching unit based on t_start
bmu = dataset.crowd_m_bmu{t_start,zi};
tpred = (t_start:t_end).';
ypred = data.trainSet{bmu.mdl_idx}.LOS.ypred{zi}(bmu.start:bmu.end);

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
plot(tpred,ypred,'-','MarkerSize', 8, 'MarkerFaceColor', 'w', 'LineWidth', 3, 'Color', 'g');

% Title and labels
title(['\fontsize{20}Level of Service for Zone #' num2str(zi)], 'FontWeight','normal');
xlabel('Time (Seconds)');
ylabel('Pedestrian Volume (pedestrian / m / min)');

% Plot axes
%axis([range(1) range(2) 0 max([max(y) max(ypred)])]);

hold off