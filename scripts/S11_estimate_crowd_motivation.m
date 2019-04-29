% DESCRIPTION: Estimate the tracks motivation at every time t.

% Clean up
clear; close all; clc;
clc; disp('Step 11.1: Clean up'); 

% Load data
clc; disp('Step 11.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% Evaluate only test tests
for trainTest = 2

    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};
        else
            dataset = data.testSet{set_i};
        end

        [time_len, zone_len] = size(dataset.crowd_state);
        
        % STEP #1: Compute crowd motivation groundtruth
        
        % crowd state motivation for the i_th set is i
        dataset.crowd_m_groundtruth = zeros(time_len, zone_len);
        dataset.crowd_m_groundtruth(:,:) = set_i;
        
        % STEP #2: Compute crowd motivation estimated
        
        % Set the window size for the number of observations to use to
        % estimate crowd motivation
        obs.max_len = 60;
        obs.start = 1;
        obs.end = 1;
        obs.y = [];
        
        % Initialize variables 
        dataset.crowd_m_est = zeros(time_len, zone_len);
        %dataset.crowd_m_est = ones(time_len, zone_len);
        dataset.crowd_m_bmu = {};
        
        % For each zone
        for zi = 1:zone_len
        
            % For each time instance
            for ti = 1:time_len-obs.max_len

                % Set indexes for observation window
                obs.start = ti; 
                obs.end = ti+obs.max_len-1;

                % Get observation vector 
                obs.y = dataset.crowd_state(obs.start:obs.end,zi);
                obs.len = length(obs.y);
                
                % Get number of training sets
                num_sets = length(data.trainSet);
                
                % Initialize variable to store best matching unit
                bmu.mse = ones(num_sets, 1) .* 1000;
                bmu.start = zeros(num_sets, 1);
                bmu.end = zeros(num_sets, 1);
                
                % For every training set
                for si = 1:num_sets
                    
                    % Update status
                    disp(strcat('Step 11.3: Processing Test set #',num2str(set_i), ...
                        ', zone ',num2str(zi), ', ti = ',num2str(ti), '/', num2str(time_len-obs.max_len), ...
                        ' train set #',num2str(si)));
                    
                    % Get number of models in training set si
                    mdl_len = length(data.trainSet{si}.LOS.ypred);
                    
                    % Check if a model exist for that zone
                    if (zi <= mdl_len)

                        % Get length of ypred
                        ypred = data.trainSet{si}.LOS.ypred{zi};
                        ypred_len = length(ypred);

                        % Slide through the model's prediction
                        for tj = 1:ypred_len-obs.len+1

                            % Compute mse
                            tj_mse = immse(ypred(tj:tj+obs.len-1),obs.y);

                            % If this is the minimum mse observed so far
                            if (tj_mse < bmu.mse)

                                % Update the minimum mse
                                bmu.mdl_idx = si;
                                bmu.mse(si) = tj_mse;
                                bmu.start(si) = tj;
                                bmu.end(si) = tj+obs.len-1;
                            end
                        end

                        % Pick the set with smallest bmu.mse
                        [~, dataset.crowd_m_est(ti,zi)] = min(bmu.mse);
                    end
                end
                
                % Store best matching unit data
                dataset.crowd_m_bmu{ti,zi} = bmu;
            end
        end
    
        % Update a dataset
        if (trainTest == 1)
            data.trainSet{set_i} = dataset;
        else
            data.testSet{set_i} = dataset;
        end
    end
end

% Save data
clc; disp('Step 11.4: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 11: Done!');
