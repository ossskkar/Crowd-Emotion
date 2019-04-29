
%======== STEP 1: INITIALIZATION %========
clc; disp('Step 1: Initialization'); 

% Clear workspace
clear; close all;

% Experiment parameters
%params_PETS
params_CSTATION

% Clean up
clearvars -except data; clc;

%======== STEP 2: CREATE TOPOLOGY MAP %========
clc; disp('Step 2: Create topology map');
%{%
% Load data
%load (data.p.s_output);

% Train topology map
eval(data.TOPO.s_script);

% Plot topology map
plot_net(data.TOPO);

% Save data
save(data.p.s_output, 'data');

% Clean up
clearvars -except data; clc;
%}%

%======== STEP 3: CREATE STATE VECTORS %========
clc; disp('Step 3: Create state vectors'); 
%{
% Load data
load (data.p.s_output);

tic

% For each training set
for i = 1:data.p.n_trainSets

    this_set = data.trainSets{i};
    
    this_set.SV.counting = [];
    this_set.SV.cos_sim  = [];
    this_set.SV.vx       = [];
    this_set.SV.vy       = [];

    tracker_sim;
    
    data.trainSets{i}.SV     = this_set.SV;
    
end


% For each testing set
for i = 1:data.p.n_testSets

    this_set        = data.testSets{i};
    
    this_set.SV.counting = [];
    this_set.SV.cos_sim  = [];
    this_set.SV.vx       = [];
    this_set.SV.vy       = [];

    tracker_sim;
    
    data.testSets{i}.SV     = this_set.SV;
    
end

toc

% Save data
%save(data.p.s_output, 'data');

% Clean up
clearvars -except data;% clc;

%}