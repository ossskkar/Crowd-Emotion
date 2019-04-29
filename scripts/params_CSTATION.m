% EXPERIMENTS PARAMETERS

% Dataset file name
data.p.s_dataset = '../data/CSTATION_DATASET_1fps';

% Output file name
data.p.s_output  = '../data/CSTATION_output_1fps';

% Load data
load (data.p.s_dataset);


% LIST OF TRAINING SETS
% train set 1 => S1L1_1 (right to left)
data.trainSets{1}.s_raw    = 'dataset';
data.trainSets{1}.s_tracks = 'tracks';

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
data.testSets = {};
%data.testSets{1}.s_raw    = 'PETS2009_S1L2_2';
%data.testSets{1}.s_tracks = 'PETS2009_S1L2_2_tracks';

% Number of testing sets
data.p.n_testSets = length(data.testSets);

%{
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
%}

% TOPOLOGY MAP
data.TOPO.s_script = 'topology_SOM';
data.TOPO.n_rows   = 10;
data.TOPO.n_columns = 5;
data.TOPO.n_neurons = data.TOPO.n_rows * data.TOPO.n_columns;
data.TOPO.n_ephocs = 100;
data.TOPO.trainSet = [];
data.TOPO.plot.s_img = '../images/cstation.jpg';
data.TOPO.plot.x = [0 720];
data.TOPO.plot.y = [0 480];
data.TOPO.plot.flag_showNet = 0;
data.TOPO.plot.f_showData = 0;
data.TOPO.plot.s_title = 'Topology Map';

% Create TOPO Training set
for i = 1:data.p.n_trainSets
    data.TOPO.trainSet = ...
        [data.TOPO.trainSet; ...
        data.trainSets{i}.raw(:,3:4)];
end


% TRACKER SIMULATOR
data.p.tracker_max_age = 4;
