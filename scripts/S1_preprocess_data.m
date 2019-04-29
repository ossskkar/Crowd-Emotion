% DESCRIPTION: Create training and test sets, add information about dataset

% Clean up
clear; close all; clc;
clc; disp('Step 1.1: Clean up'); 

% Load data
clc; disp('Step 1.2: Load data'); 
load('../data/config');

% For each data file
for df_i = 1:config.dataFiles_len
    
    load(config.dataFile_original{df_i});

    % Convert data to from pixels to meters
    %{ 
    clc; disp('Step 1.3: Convert data'); 
    [convertedPoints.x, convertedPoints.y] = tformfwd(config.convert.tform_p2m, config.convert.controlPoints.x, config.convert.controlPoints.y);
    convertedPoints.x = round(convertedPoints.x,2);
    convertedPoints.y = round(convertedPoints.y,2);

    [data.raw(:,3), data.raw(:,4)] = tformfwd(config.convert.tform_p2m, data.raw(:,3), data.raw(:,4));
    data.raw(:,3) = round(data.raw(:,3),2);
    data.raw(:,4) = round(data.raw(:,4),2);

    track_idx = unique(data.raw(:,2));
    for i = 1:length(track_idx)
        [data.tracks{track_idx(i)}(:,2), data.tracks{track_idx(i)}(:,3)] = ...
            tformfwd(config.convert.tform_p2m, data.tracks{track_idx(i)}(:,2), data.tracks{track_idx(i)}(:,3));
    end
    %}

    % Get length of raw and tracks
    [data.raw_len, ~] = size(data.raw);
    [data.tracks_len, ~] = size(data.tracks);
    %data.tracks_len = 10000; % Only for cvpr2015 # IMPORTANT!****

    % Create train set
    clc; disp('Step 1.4: Create train set'); 
    train_tracks.start_idx = 1;
    train_tracks.end_idx = round(data.tracks_len*config.trainSetPortion(df_i));
    train_tracks.idxs = (train_tracks.start_idx:train_tracks.end_idx)';
    train_raw.idxs = ismember(data.raw(:,2),train_tracks.idxs);
    
    new_data.trainSet{df_i}.raw = data.raw(train_raw.idxs,:);
    [new_data.trainSet{df_i}.raw_len, ~] = size(new_data.trainSet{df_i}.raw);
    
    new_data.trainSet{df_i}.tracks = data.tracks(train_tracks.start_idx:train_tracks.end_idx);
    [new_data.trainSet{df_i}.tracks_len, ~] = size(new_data.trainSet{df_i}.tracks);
    
    % Create test set
    clc; disp('Step 1.5: Create test set'); 
    test_tracks.start_idx = round(data.tracks_len*config.trainSetPortion(df_i)+1);
    test_tracks.end_idx = data.tracks_len;
    test_tracks.idxs = (test_tracks.start_idx:test_tracks.end_idx)';
    test_raw.idxs = ismember(data.raw(:,2),test_tracks.idxs);
    
    new_data.testSet{df_i}.raw = data.raw(test_raw.idxs,:);
    new_data.testSet{df_i}.raw(:,2) = new_data.testSet{df_i}.raw(:,2) - test_tracks.start_idx + 1; % Adjust track index
    [new_data.testSet{df_i}.raw_len, ~] = size(new_data.testSet{df_i}.raw);
    
    new_data.testSet{df_i}.tracks = data.tracks(test_tracks.start_idx:test_tracks.end_idx);
    [new_data.testSet{df_i}.tracks_len, ~] = size(new_data.testSet{df_i}.tracks);

    % Compute the actual walking speed and estimate the desired walking speed 
    % by the mean walking speed after each sample.

    % For each dataset (training and test sets)
    for set_j = 1:2

        % Select a dataset to process
        if (set_j == 1)
            dataset = new_data.trainSet{df_i};
        else
            dataset = new_data.testSet{df_i};
        end

        % Initialize variables
        dataset.tracks_v = {};
        dataset.tracks_mean_v = [];
        dataset.tracks_est_mean_v = {};

        % For each track
        for ti = 1:dataset.tracks_len

            % Update status
            disp(strcat('Step 1.6: Processing track #',num2str(ti)));

            % Get current track
            ti_data = dataset.tracks{ti}(:,2:3);
            [ti_len, ~] = size(ti_data);

            % Intialize variables
            ti_v = zeros(ti_len,1); % Walking speed at every time t
            ti_mean_v = zeros(ti_len,1); % Mean walking speed at every time t

            % Consider only tracks with more than one sample
            if (ti_len >1)

                % Convert data points from pixels to meters
                %[ti_data(:,1), ti_data(:,2)] = tformfwd(config.convert.tform_p2m, ti_data(:,1), ti_data(:,2));

                % For each point of ti
                for pi = 2:ti_len

                    % Compute velocity 
                    ti_v(pi) = sqrt((ti_data(pi,1) - ti_data(pi-1,1))^2 + (ti_data(pi,2) - ti_data(pi-1,2))^2)/config.delta_t;
                end

                % The walking speed at first sample is take as the same of the
                % second sample
                ti_v(1) = ti_v(2);

                % For each point of ti
                for pi = 1:ti_len

                    % Compute mean velocity 
                    ti_mean_v(pi) = mean(ti_v(1:pi));
                end
            end

            % Update dataset
            dataset.tracks_v{ti} = ti_v; % Actual walking speed
            dataset.tracks_mean_v(ti) = mean(ti_v); % Actual mean walking speed
            dataset.tracks_est_mean_v{ti} = ti_mean_v; % Estimated mean walking speed
        end

        % Update a dataset
        if (set_j == 1)
            new_data.trainSet{df_i} = dataset;
        else
            new_data.testSet{df_i} = dataset;
        end
    end
end

% Save data
clc; disp('Step 1.7: Save data'); 
data = new_data;
save(config.dataFile, 'data');

% Clean on exit
%clear; close all; clc;
clc; disp('Step 1: Done!');
