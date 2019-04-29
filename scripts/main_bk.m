
%======== STEP 1: CLEAR WORKSPACE %========
clc; disp('Step 1: Initialization'); 

% Experiment parameters
%params_PETS;


% Clear workspace
clear; close all; clc;

%======== STEP 2: CREATE TRAINING AND TEST SETS %========
clc; disp('Step 2: Create training and test sets'); 

% PETS09
%{
load ../data/PETS_DATASET

% Training sets
% train.set1 => S1L1_1 (right to left)
trainSet.set1.raw = PETS2009_S1L1_1;
trainSet.set1.tracks = PETS2009_S1L1_1_tracks;

% train.set2 => S1L1_2 (left to right)
trainSet.set2.raw = PETS2009_S1L1_2;
trainSet.set2.tracks = PETS2009_S1L1_2_tracks;

% train.set3 => S2L1 (left to right)
trainSet.set3.raw = PETS2009_S2L1;
trainSet.set3.tracks = PETS2009_S2L1_tracks;

% test.set1 => S1L2_2 (right to top/left/down)
testSet.set1.raw = PETS2009_S1L2_2;
testSet.set1.tracks = PETS2009_S1L2_2_tracks;

% test.set2 => S1L2_1 (left to right)
testSet.set2.raw = PETS2009_S1L2_1;
testSet.set2.tracks = PETS2009_S1L2_1_tracks;

% test.set3 => S2L2 (left to right/random/left)
testSet.set3.raw = PETS2009_S2L2;
testSet.set3.tracks = PETS2009_S2L2_tracks;

% test.set4 => S2L3 (left to right)
testSet.set4.raw = PETS2009_S2L3;
testSet.set4.tracks = PETS2009_S2L3_tracks;


% Save Training & Test sets
save ../data/PETS_train_test_sets trainSet testSet;
%}

% CSTATION
%{
load ../data/CSTATION_DATASET

% Training sets
trainSet.set1.raw = dataset;

% Testing sets
testSet = [];

% Save Training & Test sets
save ../data/CSTATION_train_test_sets trainSet testSet;
%}

clear;

%======== STEP 3: CREATE TOPOLOGY MAP %========
clc; disp('Step 3: Create topology map');
%{

% PETS09
%{
load ../data/PETS_train_test_sets

% Create training set for SOM topology
trainingSet = [trainSet.set1.raw(:,3:4); ...
               trainSet.set2.raw(:,3:4); ...
               trainSet.set3.raw(:,3:4)];

topology_SOM;

save ../data/PETS_TOPO TOPO TOPO_input TOPO_output;
%}

% PLAYGROUND
%{
load ../data/playground

trainingSet = [raw_data(:,2) -raw_data(:,3)];

topology_SOM;

save ../data/PLAY_TOPO TOPO TOPO_input TOPO_output;
%}

% CSTATION
%{
load ../data/CSTATION_train_test_sets

% Create training set for SOM topology
trainingSet = trainSet.set1.raw(1:750000,3:4);

topology_SOM;

save ../data/CSTATION_TOPO TOPO TOPO_input TOPO_output;
%}

% Plot SOM topology
plot_net(TOPO_input, TOPO_output, 0, 0, 'TOPO');

%clear;
%}
%======== STEP 4: CREATE STATE VECTORS %========
clc; disp('Step 4: Create state vectors'); 
%{%

tic
% Load data
load ../data/PETS_train_test_sets
load ../data/PETS_TOPO

% Create State vectors for training and test sets

% trainSet.set1
dataset.raw = trainSet.set1.raw;
dataset.tracks = trainSet.set1.tracks;
tracker_sim_bk
trainSet.set1.sv = sv;

% trainSet.set2
dataset.raw = trainSet.set2.raw;
dataset.tracks = trainSet.set2.tracks;
tracker_sim_bk
trainSet.set2.sv = sv;

% trainSet.set3
dataset.raw = trainSet.set3.raw;
dataset.tracks = trainSet.set3.tracks;
tracker_sim_bk
trainSet.set3.sv = sv;

% testSet.set1
dataset.raw = testSet.set1.raw;
dataset.tracks = testSet.set1.tracks;
tracker_sim_bk
testSet.set1.sv = sv;

% testSet.set2
dataset.raw = testSet.set2.raw;
dataset.tracks = testSet.set2.tracks;
tracker_sim_bk
testSet.set2.sv = sv;

% testSet.set3
dataset.raw = testSet.set3.raw;
dataset.tracks = testSet.set3.tracks;
tracker_sim_bk
testSet.set3.sv = sv;

% testSet.set4
dataset.raw = testSet.set4.raw;
dataset.tracks = testSet.set4.tracks;
tracker_sim_bk
testSet.set4.sv = sv;

% Save Training & Test sets
save ../data/PETS_train_test_sets trainSet testSet;

toc
%clear;
%}%
%======== STEP 5: CREATE SUPERSTATE MAP %========
clc; disp('Step 5: Create super-state map'); 
%{
% Load data
load ../data/PETS_train_test_sets

% Create SOM for state vector
SOM_input.trainingSet = [ trainSet.set1.sv.unified; ...
    trainSet.set2.sv.unified; trainSet.set3.sv.unified];
SOM_sv;

% Get classes for all datasets (training/testing sets)
trainSet.set1.sv.unified_classes = vec2ind(SOM(trainSet.set1.sv.unified.'));
trainSet.set2.sv.unified_classes = vec2ind(SOM(trainSet.set2.sv.unified.'));
trainSet.set3.sv.unified_classes = vec2ind(SOM(trainSet.set3.sv.unified.'));
testSet.set1.sv.unified_classes = vec2ind(SOM(testSet.set1.sv.unified.'));
testSet.set2.sv.unified_classes = vec2ind(SOM(testSet.set2.sv.unified.'));
testSet.set3.sv.unified_classes = vec2ind(SOM(testSet.set3.sv.unified.'));
testSet.set4.sv.unified_classes = vec2ind(SOM(testSet.set4.sv.unified.'));

% Save data
save ../data/PETS_SOM SOM SOM_input;
save ../data/PETS_train_test_sets trainSet testSet;

clear;
%}%
%======== STEP 6: CREATE HMM MODELS %========
clc; disp('Step 6: Create HMM models'); 
%{%
load ../data/PETS_train_test_sets;
load ../data/PETS_SOM;

hmm.num_states = SOM_input.params.rows * SOM_input.params.columns;

% States and seq for model 1
hmm.model1.seq = [trainSet.set1.sv.unified].';
hmm.model1.states = [trainSet.set1.sv.unified_classes];
hmm.model1.seq = hmm.model1.seq+1; %compesation because a sequence of 0 is not valid

% States and seq for model 2
hmm.model2.seq = [trainSet.set2.sv.unified].';
hmm.model2.states = [trainSet.set2.sv.unified_classes];
hmm.model2.seq = hmm.model2.seq+1; %compesation because a sequence of 0 is not valid

% States and seq for model 3
hmm.model3.seq = [trainSet.set3.sv.unified].';
hmm.model3.states = [trainSet.set3.sv.unified_classes];
hmm.model3.seq = hmm.model3.seq+1; %compesation because a sequence of 0 is not valid

% Create time scale
hmm.max_scale = 30;
hmm.time_scale = create_time_scale([hmm.model1.states hmm.model2.states hmm.model3.states], hmm.max_scale);

% Create HMMs
hmm.model1.TRANS = create_HMM(hmm.model1.seq, hmm.model1.states, hmm.time_scale, hmm.num_states);
hmm.model2.TRANS = create_HMM(hmm.model2.seq, hmm.model2.states, hmm.time_scale, hmm.num_states);
hmm.model3.TRANS = create_HMM(hmm.model3.seq, hmm.model3.states, hmm.time_scale, hmm.num_states);

save ../data/PETS_hmm hmm;

clear;
%}%
%======== STEP 7: TEST HMM MODELS %========

clc; disp('Step 7: Test HMM models'); 

%{%
load ../data/PETS_train_test_sets;
load ../data/PETS_hmm;

% Use TRANS to estimate probability prediction 
states = testSet.set3.sv.unified_classes.';
cum_pp1 = zeros(length(states),1);
cum_pp2 = zeros(length(states),1);
cum_pp3 = zeros(length(states),1);
ps_m1 = zeros(length(states),1);
ps_m2 = zeros(length(states),1);
ps_m3 = zeros(length(states),1);

tt = zeros(length(states),1);

for t = 2:length(states)
    
    tt(t) = t;
    
    % Find time scale index
    ts_idx = min(find(hmm.time_scale >= t));
    if (isempty(ts_idx))
        ts_idx = max(find(hmm.time_scale <= t));
    end
    
    % Predicted state of model 1
    ps_m1(t) = min(find(hmm.model1.TRANS(states(t),:,ts_idx) == max(hmm.model1.TRANS(states(t),:,ts_idx))));
    cum_pp1(t) = sum(states(1:t) == ps_m1(1:t))/length(states(1:t));
    
    % Predicted state of model 1
    ps_m2(t) = min(find(hmm.model2.TRANS(states(t),:,ts_idx) == max(hmm.model2.TRANS(states(t),:,ts_idx))));
    cum_pp2(t) = sum(states(1:t) == ps_m2(1:t))/length(states(1:t));
    
    % Predicted state of model 1
    ps_m3(t) = min(find(hmm.model3.TRANS(states(t),:,ts_idx) == max(hmm.model3.TRANS(states(t),:,ts_idx))));
    cum_pp3(t) = sum(states(1:t) == ps_m3(1:t))/length(states(1:t));
    
end

% Compute accuracy
m1.positive = 0;
m2.positive = 0;
m3.positive = 0;
n_states = length(states);
for i = 1:n_states
    if (ps_m1(i) == states(i))
        m1.positive = m1.positive + 1;
    end
    
    if (ps_m2(i) == states(i))
        m2.positive = m2.positive + 1;
    end
    
    if (ps_m3(i) == states(i))
        m3.positive = m3.positive + 1;
    end
end

acurracy = [m1.positive/n_states m2.positive/n_states m3.positive/n_states]



%plot(tt, cum_pp1, tt, cum_pp2, tt, cum_pp3)
%}