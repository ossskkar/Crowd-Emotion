% DESCRIPTION:
% Create SOM for state vectors of crowd.
% Obtain training set, create SOM, train SOM, obtain boundaries and save
% data

% Clear workspace
%clear_workspace;

% Create SOM Training set
%load ../data/PETS_sv

%sv.cos_sim(isnan(sv.cos_sim)) = 0;
%SOM_input.trainingSet = sv.cos_sim;
%SOM_input.trainingSet = sv.counting;

% SOM Parameters
SOM_input.params.rows    = 7;
SOM_input.params.columns = 5;
SOM_input.params.epochs  = 200;

% Create SOM
clc; disp('creating SOM'); 
SOM = selforgmap([SOM_input.params.rows, SOM_input.params.columns]);

% Configure SOM
SOM = configure(SOM, SOM_input.trainingSet.');

% Train SOM
clc; disp('training SOM'); 
SOM.trainParam.epochs = SOM_input.params.epochs;
SOM = train(SOM, SOM_input.trainingSet.');

% Get weights(position of neurons)
%SOM_output.weight = cell2mat(SOM.IW);

% Get classes
%clc; disp('clustering SOM'); 
%SOM_output.classes = ...
%    net_cluster(SOM_output.weight, SOM_input.trainingSet);

% Find boudary of zones
%[SOM_output.bnds, SOM_output.edges] = ...
%    net_inf(SOM_input.trainingSet, SOM_output.weight);
