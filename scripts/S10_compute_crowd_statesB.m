% DESCRIPTION: Plot Level of Service for one zone

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);
load(config.LOSFile);

% Zone to plot
zi = 25;

% Time interval to plot
time.start = 1;
%time.end = length(unique(data.trainSet.raw(:,1)));
time.end = 100;
time.min_interval = 30;

% Get data
data = data.trainSet.crowd_state(time.start:time.end,zi);
t = [time.start:time.end].';

startPoint = time.start;

g.template.x = [];
g.template.y = [];
g.template.a = 0;
g.template.center = 0;
g.template.sigma = 0.1;
g.template.shift = 0;

g.rmse = 1000;
g.prev_rmse = g.rmse+1;
g.min_rmse_gain = 0.001;
g.learning_rate = 0.1;
g.n_params = 4;

g.main.x = time.start:time.end;
g.main.x_smooth = time.start:0.1:time.end;
g.main.y = zeros(length(g.main.x),1);
g.main.y_smooth = zeros(length(g.main.x_smooth),1);
g.models{1} = g.template;
g.len = 1;

% For each point in the interval
for ti = startPoint:time.end
    
    % Evaluate curves that have more than the minimum number of samples
    if (ti - startPoint) >= time.min_interval

        % Update range of data
        g.models{g.len}.range = [startPoint, ti];
        
        if ((g.rmse - g.prev_rmse) > g.min_rmse_gain)
            % Optimize parameters for g
            g = optimize_gauss(g, data);
        else
            % Optimize parameters for current model
            g.models{g.len}.range(2) = g.models{g.len}.range(2)-1;
            g = optimize_gauss(g, data);
            
            break;
        end 
    end
end

disp(['FINAL: Range = [' num2str(g.models{g.len}.range) '], RMSE = ' num2str(g.rmse)]);

% Generate smooth gaussian curve
g.models{g.len}.x_smooth = time.start:0.1:time.end;
g.models{g.len}.y_smooth = (g.models{g.len}.a * gaussmf(g.models{g.len}.x_smooth, [g.models{g.len}.sigma, g.models{g.len}.center]))';

close all
hold on
plot(g.models{g.len}.x_smooth, g.models{g.len}.y_smooth, 'g');
plot(data,'.k');
plot(data(g.models{g.len}.range(1):g.models{g.len}.range(2)),'*g');
hold off
axis([time.start time.end 0 max(data)])
