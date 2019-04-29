% DESCRIPTION: Plot tracks of a given dataset

% Clean up
clear; close all; clc;
clc; disp('Clean up'); 

load('../data/config');


% Get density
for i = 1:config.dataFiles_len
    load(config.dataFile_original{i});
    
    t = unique(data.raw(:,1));
    density{i} = zeros(1,length(t));
    for ti = 1:length(t)
        density{i}(ti) = length(find(data.raw(:,1) == t(ti)));
    end    
end

% Get mean max walking speed for each dataset
load(config.dataFile);
for i = 1:config.dataFiles_len
    
    disp(strcat('Dataset --', num2str(i), '--mean=', ...
        num2str(mean([data.trainSet{i}.tracks_mean_v data.testSet{i}.tracks_mean_v])), ...
        '--max=', num2str(max([data.trainSet{i}.tracks_mean_v data.testSet{i}.tracks_mean_v]))));    
end


