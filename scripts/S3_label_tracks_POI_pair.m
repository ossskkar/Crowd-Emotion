% DESCRIPTION: Cluster tracks by Origin-Dest POI pair

mfilename

% Clean up
clear; close all; clc;
clc; disp('Step 3.1: Clean up'); 

% Load data
clc; disp('Step 3.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% For training/test sets
for trainTest = 1:2

    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};
        else
            dataset = data.testSet{set_i};
        end

        % Initialize variables
        dataset.tracks_POI_pair = zeros(dataset.tracks_len,2);

        % For each track
        for ti = 1:dataset.tracks_len

            % Update status
            disp(strcat('Step 3.3: Processing track #',num2str(ti)));

            % Get track ti
            ti_track = dataset.tracks{ti}(:,2:3);

            % Get track lenght
            [ti_len, ~] = size(ti_track);

            % Origen and destination attractors with minimum distance to initial
            % and final point to track ti
            min_POI_origin_dist = 0;
            min_POI_dest_dist   = 0;

            % for each POI
            for ai = 1:data.POI.len

                % Compute the minimum distance between initial point and attractor points
                ai_dist = min(pdist2(ti_track(1,:),data.POI.groundtruth{ai}.p));

                % Check if attractor ai is the closest to initial point of track ti
                if (ai_dist < config.POIDist_treshold)
                    dataset.tracks_POI_pair(ti,1) = ai;
                    min_POI_origin_dist = ai_dist;
                end

                % Compute the minimum distance between final point and attractor points
                ai_dist = min(pdist2(ti_track(ti_len,:),data.POI.groundtruth{ai}.p));

                % Check if attractor ai is the closest to final point of track ti
                if (ai_dist < config.POIDist_treshold)
                    dataset.tracks_POI_pair(ti,2) = ai;
                    min_POI_dest_dist = ai_dist;
                end
            end
        end

        % Update status
        disp('Step 3.4: Label tracks with a POI pair ');

        % For each POI pair
        for pai = 1:data.POI.pairs_len

            % Find pair index
            [~, pa_idxs] = ismember(dataset.tracks_POI_pair(:,1:2), data.POI.pairs(pai,:),'rows');

            % Assign pair index
            dataset.tracks_POI_pair(find(pa_idxs ~= 0),3) = pai;
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
clc; disp('Step 3.5: Save data'); 
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 3: Done!');
