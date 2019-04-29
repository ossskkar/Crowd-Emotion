% DESCRIPTION: Estimate the tracks motivation at every time t.

% Clean up
clear; close all; clc;
clc; disp('Step 12.1: Clean up'); 

% Load data
clc; disp('Step 12.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% Get all the attractors points (needed later)
att_all_p = [];
for ai = 1:data.POI.len
    att_all_p = [att_all_p; data.POI.groundtruth{ai}.p];
end

% Evaluate only test tests
for trainTest = 2%1:2

    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};
        else
            dataset = data.testSet{set_i};
        end

        % Intialize variables 
        dataset.tracks_m_est = {};
        dataset.tracks_m_est_accuracy = [];

        % For each track
        for ti = 1:dataset.tracks_len

            % Update status
            disp(strcat('Step 12.3: Processing track #',num2str(ti)));

            % Get current track
            ti_data = dataset.tracks{ti}(:,2:3);
            [ti_len, ~] = size(ti_data);
            t0 = 1;

            % Initialize vector for motivation estimation
            m = zeros(1,ti_len);

            % Start clock
            tic;

            % Initialize vector to acumulate innovation for each attractor
            att_innovation = zeros(data.POI.len,1);

            % Flag variable to indicate whether the previous point is in an attractor
            in_attractor(2) = ismember(round(ti_data(t0,:)),att_all_p,'rows');

            % For each POI
            m_origin = -1;
            closest_dist = -1;
            for ai = 1:data.POI.len

                % Find the minimum distance between the last point in y and
                % the points of attractor ai
                m_origin_dist = min(pdist2(ti_data(1,:),data.POI.groundtruth{ai}.p));

                % If this is the current minimum distance among attractors
                if ((closest_dist == -1) || m_origin_dist < closest_dist)

                    % Update the minimum distance
                    closest_dist = m_origin_dist;

                    % label the last point of y with attractor ai
                    m_origin = ai;
                end
            end

            % Estimate initial motivation from A Priori
            [~, dataset.tracks_m_est{ti}(1)] = max(data.POI.apriori(m_origin,:));

            % For each point of ti
            for pj = 2:ti_len

                % Check if current point is in an attractor
                in_attractor(1) = in_attractor(2);
                in_attractor(2) = ismember(round(ti_data(pj,:)),att_all_p,'rows');

                % Changing from been in an attractor to not been, signals a change
                % of segment
                if (in_attractor(1) == 1 && in_attractor(2) == 0)

                    % Update initial segment point
                    t0 = pj;

                    % Initialize vector to acumulate innovation for each attractor
                    att_innovation = zeros(data.POI.len,1);

                % If the number of observations is bigger than sliding window or 
                % surpass the distance threshold    
                %elseif (((pj - t0) > config.sw_size) || (data.tracks_tot_dist(ti) > config.dist_threshold))
                elseif ((pj - t0) > config.sw_size)

                    % Update initial segment point
                    t0 = pj;

                    % Initialize vector to acumulate innovation for each attractor
                    att_innovation = zeros(data.POI.len,1);
                end

                % Get mean velocity at point pi
                pi_mean_v = dataset.tracks_est_mean_v{ti}(pj);

                % For each attractor
                for ai = 1:data.POI.len

                    % Compute the expected point
                    p_exp = ti_data(pj-1,:);
                    cp = [round(ti_data(pj-1,2)), round(ti_data(pj-1,1))];
                    if (cp(1) == 0) cp(1) = 1; end
                    if (cp(2) == 0) cp(2) = 1; end

                    p_exp(1) = p_exp(1) + pi_mean_v * data.POI.groundtruth{ai}.df_x(cp(1), cp(2));
                    p_exp(2) = p_exp(2) + pi_mean_v * data.POI.groundtruth{ai}.df_y(cp(1), cp(2));

                    % Compute innovation
                    att_innovation(ai,1) = att_innovation(ai,1) + ...
                        sqrt((ti_data(pj,1) - p_exp(1))^2 + (ti_data(pj,2) - p_exp(2))^2);
                end

                % The predicted motivation corresponds to the attractor with
                % smalles innovation
                [~, m(pj)] = min(att_innovation);

            end

            % Check time elapsed
            t = toc;

            % Save the record of predicted motivations
            dataset.tracks_m_est{ti}(2:ti_len) = m(2:ti_len);

            % Compute prediction accuracy for track ti
            %dataset.tracks_m_est_accuracy(ti) = length(find(dataset.tracks_m_groundtruth{ti} == m))/length(dataset.tracks{ti});

            % Compute prediction accuracy for track ti after observing half track
            dataset.tracks_m_est_accuracy(ti) = length(find(dataset.tracks_m_groundtruth{ti}(round(ti_len/2):ti_len) == m(round(ti_len/2):ti_len)))/(round(ti_len/2));
            if (dataset.tracks_m_est_accuracy(ti) > 1) 
                dataset.tracks_m_est_accuracy(ti) = 1; 
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
clc; disp('Step 12.4: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 12: Done!');
