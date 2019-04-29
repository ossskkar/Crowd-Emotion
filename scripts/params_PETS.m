% EXPERIMENTS PARAMETERS

% Dataset file name
data.p.s_dataset = '../data/PETS_DATASET';

% Output file name
data.p.s_output  = '../data/PETS_output';

% Load data
load (data.p.s_dataset);


% LIST OF TRAINING SETS
% train set 1 => S1L1_1 (right to left)
data.trainSets{1}.s_raw    = 'PETS2009_S1L1_1';
data.trainSets{1}.s_tracks = 'PETS2009_S1L1_1_tracks';

% train set 2 => S1L1_2 (left to right)
data.trainSets{2}.s_raw    = 'PETS2009_S1L1_2';
data.trainSets{2}.s_tracks = 'PETS2009_S1L1_2_tracks';

% train set 3 => S2L1 (left to right)
data.trainSets{3}.s_raw    = 'PETS2009_S2L1';
data.trainSets{3}.s_tracks = 'PETS2009_S2L1_tracks';

% Number of training sets
data.p.n_trainSets = length(data.trainSets);

% Training sets
for i = 1:data.p.n_trainSets
    data.trainSets{i}.raw    = eval(data.trainSets{i}.s_raw);
    data.trainSets{i}.tracks = eval(data.trainSets{i}.s_tracks);
    
    data.trainSets{i}.SV.counting = [];
    data.trainSets{i}.SV.cos_sim = [];
    data.trainSets{i}.SV.vx = [];
    data.trainSets{i}.SV.vy = [];
    
    data.trainSets{i}.time_start = min(data.trainSets{i}.raw(:,1));
    data.trainSets{i}.time_end   = max(data.trainSets{i}.raw(:,1));
end


% LIST OF TESTING SETS
% Test set 1 => S1L2_2 (right to top/left/down)
data.testSets{1}.s_raw    = 'PETS2009_S1L2_2';
data.testSets{1}.s_tracks = 'PETS2009_S1L2_2_tracks';

% Test set 2 => S1L2_1 (left to right)
data.testSets{2}.s_raw    = 'PETS2009_S1L2_1';
data.testSets{2}.s_tracks = 'PETS2009_S1L2_1_tracks';

% Test set 3 => S2L2 (left to right/random/left)
data.testSets{3}.s_raw    = 'PETS2009_S2L2';
data.testSets{3}.s_tracks = 'PETS2009_S2L2_tracks';

% Test set 4 => S2L3 (left to right)
data.testSets{4}.s_raw    = 'PETS2009_S2L3';
data.testSets{4}.s_tracks = 'PETS2009_S2L3_tracks';

% Number of testing sets
data.p.n_testSets = length(data.testSets);

% Testing sets
for i = 1:data.p.n_testSets
    data.testSets{i}.raw    = eval(data.testSets{i}.s_raw);
    data.testSets{i}.tracks = eval(data.testSets{i}.s_tracks);
    
    data.testSets{i}.SV.counting = [];
    data.testSets{i}.SV.cos_sim = [];
    data.testSets{i}.SV.vx = [];
    data.testSets{i}.SV.vy = [];
    
    
    data.testSets{i}.time_start = min(data.testSets{i}.raw(:,1));
    data.testSets{i}.time_end   = max(data.testSets{i}.raw(:,1));
end


% TOPOLOGY MAP
data.TOPO.s_script = 'topology_SOM';
data.TOPO.n_rows   = 2;
data.TOPO.n_columns = 5;
data.TOPO.n_neurons = data.TOPO.n_rows * data.TOPO.n_columns;
data.TOPO.n_ephocs = 500;
data.TOPO.trainSet = [];
data.TOPO.plot.s_img = '../images/PETS09.jpg';
data.TOPO.plot.x = [0 768];
data.TOPO.plot.y = [0 576];
data.TOPO.plot.flag_showNet = 0;
data.TOPO.plot.f_showData = 1;
data.TOPO.plot.s_title = 'Topology Map';

% Create TOPO Training set
for i = 1:data.p.n_trainSets
    data.TOPO.trainSet = ...
        [data.TOPO.trainSet; ...
        data.trainSets{i}.raw(:,3:4)];
end


% TRACKER SIMULATOR
data.p.tracker_max_age = 4;
