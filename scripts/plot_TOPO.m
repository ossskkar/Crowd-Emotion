% DESCRIPTION: Plot topology in colored zones

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% FIGURE #1: Only background image

% Plot background image
figure;
img = imread(config.imgFile);
imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
set(gca,'YDir','normal')

% Hide axis and box
axis off
box off

% Crop white space in figure
ax = gca;
outerpos = ax.OuterPosition;
left = 0;
bottom = outerpos(2);
ax_width = outerpos(3);
ax_height = outerpos(4);
ax.Position = [left bottom ax_width ax_height];

% Save figure to file
print('../figures/TOPO_a','-dpng');


% FIGURE #2: Background image with training set

% Plot background image
figure;
img = imread(config.imgFile);
imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

plot(data.TOPO.trainSet(:,1), data.TOPO.trainSet(:,2),'.g', 'MarkerSize', 1);

hold off

% Hide axis and box
axis off
box off

% Crop white space in figure
ax = gca;
outerpos = ax.OuterPosition;
left = 0;
bottom = outerpos(2);
ax_width = outerpos(3);
ax_height = outerpos(4);
ax.Position = [left bottom ax_width ax_height];

% Save figure to file
print('../figures/TOPO_b','-dpng');


% FIGURE #3: Background image with zones

% Plot background image
figure;
img = imread(config.imgFile);
imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

t_data = data.TOPO.trainSet;

% Plot training data
if (config.TOPO.plot.f_showData)    
    scatter(t_data(:,1), t_data(:,2), 10, 'g');
end

% For each class (zone)
for i = 1:config.TOPO.params.n_neurons

    % Get the indexes of boundary data points of zone i
    bnd = data.TOPO.output.bnds{i};

    t_data_i = t_data(find(data.TOPO.output.classes == i),:);
    

    % Plot boundary of zone i
    fill(t_data_i(bnd,1), t_data_i(bnd,2),[rand rand rand],'EdgeColor','k', 'LineWidth', 2, 'FaceAlpha',0.5);

    % Neuron number
    text(data.TOPO.output.weight(i,1)-5, data.TOPO.output.weight(i,2), num2str(i), 'FontSize', 20, 'Color', 'k');

end

config.TOPO.plot.f_showNet = 0;
% Plot network
if (config.TOPO.plot.f_showNet)

    % Plot edges
    for i = 1:(length(data.TOPO.output.edges)-1)
        plot(data.TOPO.output.weight(data.TOPO.output.edges(i,:),1),-data.TOPO.output.weight(data.TOPO.output.edges(i,:),2), 'b', 'LineWidth', 1);
    end

    % Plot neurons
    scatter(data.TOPO.output.weight(:,1), -data.TOPO.output.weight(:,2), 60, 'y', 'filled');
    scatter(data.TOPO.output.weight(:,1), -data.TOPO.output.weight(:,2), 30, 'r', 'filled');

end

hold off;

% Hide axis and box
axis off
box off

% Crop white space in figure
ax = gca;
outerpos = ax.OuterPosition;
left = 0;
bottom = outerpos(2);
ax_width = outerpos(3);
ax_height = outerpos(4);
ax.Position = [left bottom ax_width ax_height];

% Save figure to file
print('../figures/TOPO_c','-dpng');
