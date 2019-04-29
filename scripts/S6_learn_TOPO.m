% DESCRIPTION:
% Obtain training set, create self-organising map TOPO, train TOPO, 
% obtain boundaries and save data

% Clean up
clear; close all; clc;
clc; disp('Step 6.1: Clean up'); 

% Load data
clc; disp('Step 6.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

data.TOPO.trainSet = [];

% For each training set
for set_i = 1:length(data.trainSet)

    % Create combined train set
    clc; disp('Step 6.3: Create train and test sets'); 
    data.TOPO.trainSet = [data.TOPO.trainSet; data.trainSet{set_i}.raw(:,3:4)];
end

% Create SOM
clc; disp('Step 6.4: Create SOM'); 

data.TOPO.net = selforgmap([config.TOPO.params.n_rows, config.TOPO.params.n_columns]);
data.TOPO.net = configure(data.TOPO.net, data.TOPO.trainSet.');
data.TOPO.n_neurons = config.TOPO.params.n_neurons;

% Train TOPO
clc; disp('Step 6.5: Train SOM'); 
data.TOPO.net.trainParam.epochs = config.TOPO.params.n_ephocs;
data.TOPO.net = train(data.TOPO.net, data.TOPO.trainSet.');

% Get weights(position of neurons)
data.TOPO.output.weight = cell2mat(data.TOPO.net.IW);

% Get classes
clc; disp('Step 6.6: Get classes'); 
data.TOPO.output.classes = net_cluster(data.TOPO.output.weight, data.TOPO.trainSet);

% Find boudary of zones
clc; disp('Step 6.7: Find boundaries'); 
[data.TOPO.output.bnds, data.TOPO.output.edges] = net_inf(data.TOPO.trainSet, data.TOPO.output);

% Compute area per zone
clc; disp('Step 6.8: Compute area per zone'); 
for i = 1:config.TOPO.params.n_neurons
    
    % Get index of boundary points
    bnd = data.TOPO.output.bnds{i};
    
    % Get data points belonging to this zone (in pixels)
    t_data_p = data.TOPO.trainSet(data.TOPO.output.classes == i,:);
    
    % Get data points belonging to this zone (in meters)
    t_data_m = [];
    [t_data_m(:,1), t_data_m(:,2)] = ...
        tformfwd(config.convert.tform_p2m, t_data_p(:,1), t_data_p(:,2));
    
    % Compute area (in pixels^2)
    data.TOPO.output.area_p(i) = polyarea(t_data_p(bnd,1), t_data_p(bnd,2));
    
    % Compute area (in meters^2)
    data.TOPO.output.area_m(i) = polyarea(t_data_m(bnd,2), t_data_m(bnd,1));
end

% Save data
clc; disp('Step 6.9: Save data'); 
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 6: Done!');

