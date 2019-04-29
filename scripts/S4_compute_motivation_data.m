% DESCRIPTION: Compute motivation for tracks in train and test sets

% Clean up
clear; close all; clc;
clc; disp('Step 4.1: Clean up'); 

% Load data
clc; disp('Step 4.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% For training/test sets
for trainTest = 1:2

    % Initialize Motivation A Priori (only for training sets)
    if (trainTest == 1)
        data.POI.apriori = zeros(data.POI.len);
    end
    
    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};            
        else
            dataset = data.testSet{set_i};
        end

        % Initialize variables
        dataset.tracks_m_groundtruth = {};

        % For each track
        for yi = 1:length(dataset.tracks)

            % Update status
            disp(strcat('Step 4.3: Processing track #',num2str(yi)));

            % Get current track
            y = dataset.tracks{yi}(:,2:3);

            % Get length of y
            [y_len, ~] = size(y);

            % Initialize labels vector
            y_label = zeros(1,y_len);

            % Find points of y crossing attractor ai
            for ai = 1:data.POI.len
                y_label(ismember(round(y),data.POI.groundtruth{ai}.p,'rows')) = ai;    
            end

            % For tracks that did not start within an attractor boundary
            if (y_label(1) == 0)
                closest_dist = -1;

                % For each attractor
                for ai = 1:data.POI.len

                    % Find the minimum distance between the last point in y and
                    % the points of attractor ai
                    att_dist = min(pdist2(y(1,:),data.POI.groundtruth{ai}.p));

                    % If this is the current minimum distance among attractors
                    if ((closest_dist == -1) || att_dist < closest_dist)

                        % Update the minimum distance
                        closest_dist = att_dist;

                        % label the last point of y with attractor ai
                        y_label(1) = ai;
                    end
                end
            end

            % For tracks that did not reach their final destination
            if (y_label(y_len) == 0)
                closest_dist = -1;

                % For each attractor
                for ai = 1:data.POI.len

                    % Find the minimum distance between the last point in y and
                    % the points of attractor ai
                    att_dist = min(pdist2(y(y_len,:),data.POI.groundtruth{ai}.p));

                    % If this is the current minimum distance among attractors
                    if ((closest_dist == -1) || att_dist < closest_dist)

                        % Update the minimum distance
                        closest_dist = att_dist;

                        % label the last point of y with attractor ai
                        y_label(y_len) = ai;
                    end
                end
            end

            % Assign label points in y
            for yj = y_len-1:-1:1
                if (y_label(yj) == 0)
                    y_label(yj) = y_label(yj+1);
                end
            end

            % Update groundtruth labels for track yi
            dataset.tracks_m_groundtruth{yi} = y_label;

            % Compute motivation apriori using only training sets
            if (trainTest == 1)

                % Obtain unique POI pairs
                m = y_label;
                m(diff(m)==0) = [];
                m_len = length(m);

                % Consider only tracks with more than one motivation (including 
                % origin and destination motivations)
                if (m_len > 1)
                    for mi = 2:m_len

                        % Compute motivation a priori
                        data.POI.apriori(m(mi-1),m(mi)) = data.POI.apriori(m(mi-1),m(mi)) + 1;
                    end
                end
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
clc; disp('Step 4.4: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 4: Done!');
