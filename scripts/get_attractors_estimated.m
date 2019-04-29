% DESCRITPION: Using data from Damian's method, compute the attractors 
%              points, boundaries and direction field.

% Clean up
disp('Cleaning up');
clear; close all; clc;

% Load data
disp('Loading data');

load ../data/data;
load ../data/attractors;

% Attractors estimation from Damian's process
v{1} = load('../data/attractive_points_results/MergedCentersOfForce1v25');
v{2} = load('../data/attractive_points_results/MergedCentersOfForce2v25');
v{3} = load('../data/attractive_points_results/MergedCentersOfForce3v25');
v{4} = load('../data/attractive_points_results/MergedCentersOfForce4v25');
v{5} = load('../data/attractive_points_results/MergedCentersOfForce5v25');

% Trajectories from different datasets
dset{1} = load('../data/sim_amb_nonpeak_dlow_wfast');
dset{2} = load('../data/sim_amb_nonpeak_dlow_wnormal');
dset{3} = load('../data/sim_amb_nonpeak_dlow_wpanic');
dset{4} = load('../data/sim_amb_nonpeak_dlow_wslow');
dset{5} = load('../data/sim_amb_nonpeak_dmed_wslow');

% Get centroids of doors based on trajectories
salient.p = [];
for di = 1:length(dset)
    
    % For each track
    for ti = 1:length(dset{di}.data.tracks)
        
        % Add initial point
        salient.p = [salient.p; dset{di}.data.tracks{ti}(1,2:3)];
    end
end

% Cluster salient points
salient.cluster = clusterdata(salient.p,'maxclust',14);

% Create heat map for doors
hm_doors = zeros(data.inf.frame_size(2), data.inf.frame_size(1));

% Radius of attractor 
r = 20;

% Mesh for attractors mask
[x y] = meshgrid(1:data.inf.frame_size(1), 1:data.inf.frame_size(2));

total_p = length(salient.p);

% For each salient cluster
for si = 1:max(salient.cluster)
    
    % Get salient centroid
    salient.centroid.p(si,1:2) = mean(salient.p(salient.cluster==si,:));
    
    % Get salient count for each centroid
    salient.centroid.count(si) = length(salient.p(salient.cluster==si,:));    
    
    % Multiple levels of shading for heat map of doors
    for li = 1:10
        % Next create the circle in the image.
        this_mask = (x - salient.centroid.p(si,1)).^2 ...
        + (y - salient.centroid.p(si,2)).^2 <= (r/li).^2;
        hm_doors = hm_doors + (30*(salient.centroid.count(si) / total_p)*this_mask.*(1/li));
    end
    
end

% Initialize heat map for attractors
hm_attractors = zeros(size(v{1}.funPlot));

% For each data result
for vi = 1:length(v)
    
    % Correct orientation
    v{vi}.meanCentersPlot(2,:) = data.inf.frame_size(2) - v{vi}.meanCentersPlot(2,:);
    
    % Add up to heat map data
    hm_attractors = hm_attractors + v{vi}.funPlot;
end

% Correct orientation
hm_attractors = flipud(hm_attractors);

% Generate mask to filter out false attractors
hm_mask = zeros(size(hm_attractors));

% Attractors list (keep these ones)
a_list = [1, 4, 8, 10, 11, 12, 13, 14];

% Position of attractors
a_pos = round(v{1}.meanCentersPlot).';

% For each attractor in the list
for ai = 1:length(a_list)
    
    % Multiple levels of shading
    for li = 1:10
        % Next create the circle in the image.
        this_mask = (x - a_pos(a_list(ai),1)).^2 ...
        + (y - a_pos(a_list(ai),2)).^2 <= (r/li).^2;
        hm_mask = hm_mask + (this_mask.*(1/li));
    end
end

% Organize attractors data
attractors.estimated.heatmap=hm_doors + (hm_mask.*hm_attractors);
attractors.estimated.centroids = [salient.centroid.p; a_pos(a_list,:)];

% Save data
disp('Saving data');
save ../data/attractors attractors

disp('Done!');

