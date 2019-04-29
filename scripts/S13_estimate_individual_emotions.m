% DESCRIPTION: Compute actual and expected DTM, and estimate individual 
%              emotions.

% Clean up
clear; close all; clc;
clc; disp('Step 13.1: Clean up'); 

% Load data
clc; disp('Step 13.2: Load data'); 
load('../data/config');
load(config.dataFile);

% For training/test sets
for trainTest = 2

    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};
        else
            dataset = data.testSet{set_i};
        end

        % Initialize variables
        dataset.tracks_emotion_est = {};
        dataset.tracks_emotion_mse(1:dataset.tracks_len) = nan;

        % For each track
        for ti = 1:dataset.tracks_len

            % Update status
            disp(strcat('Step 13.3: Processing track #',num2str(ti)));

            % Ge track data
            ti_track = [];
            ti_track(:,2:3) = dataset.tracks{ti}(:,2:3);
            [ti_len, ~] = size(ti_track);
            ti_track(:,1) = (0:config.delta_t:config.delta_t*(ti_len-1)); % timestamp is manualy computed

            % Get the zone corresponding to each position of track ti
            ti_track(:,4) = net_cluster(data.TOPO.output.weight, ti_track(:,2:3));
            
            % Get time row number in dataset.crowd_state corresponding to
            % the data points in track ti
            [~, idx] = ismember(unique(dataset.raw(:,1)), dataset.tracks{ti}(:,1));
            idx(idx== 0) = [];
            ti_track(:,5) = idx;
            
            % Get POI of origin based on initial position
            ti_POI_origin = get_POI_origin(ti_track(1,2:3), data.POI, config.POIDist_treshold);

            % Get estimated motivations at every time t
            ti_track_m_est = dataset.tracks_m_est{ti};

            % Get estimated desired walking speed at every time t
            ti_track_mean_v = dataset.tracks_est_mean_v{ti};

            % Initialize variables
            ti_track_dist_traveled = zeros(ti_len,1);
            ti_track_total_dist_traveled = zeros(ti_len,1);
            dataset.tracks_emotion_est{ti} = zeros(ti_len,1);

            crowd_m = 0;
           
            % For each point pi of track ti
            for pi = 1:ti_len

                % Current POI pair
                ti_POI_pair = [ti_POI_origin ti_track_m_est(pi)];

                % Current crowd motivation (indicates from which training 
                % set should the DTM and EMOTION be taken).
                last_crowd_m = crowd_m;
                crowd_m = dataset.crowd_m_est(ti_track(pi,5), ti_track(pi,4)); 
                
                % If the new crowd motivation is 0, use the last known
                % motivation
                if (crowd_m == 0)
                    crowd_m = last_crowd_m;
                end
                
                % Get POI pair index
                [~, ti_POI_pair_idx] = ismember(ti_POI_pair, data.POI.pairs(:,1:2), 'rows');

                if (any(ti_POI_pair_idx) && ~isempty(data.trainSet{crowd_m}.DTM{ti_POI_pair_idx}.len))

                    % Compute distance traveled from point pi-1 to pi
                    if (pi > 1)
                        ti_track_dist_traveled(pi) = sqrt((ti_track(pi,2) - ti_track(pi-1,2)).^2 + (ti_track(pi,3) - ti_track(pi-1,3)).^2);
                        ti_track_total_dist_traveled(pi) = sum(ti_track_dist_traveled(1:pi));
                    end

                    % Get expected distance from the initial distance of DTM for
                    % the given POI pair
                    ti_exp_dist = data.trainSet{crowd_m}.DTM{ti_POI_pair_idx}.mean_dist(1);
                    if (ti_exp_dist < ti_track_total_dist_traveled(pi))
                        ti_exp_dist = ti_track_total_dist_traveled(pi);
                    end

                    % Compute actual DTM from point 1 to pi
                    ti_dtm_actual.dist(1:pi) = ti_exp_dist - ti_track_total_dist_traveled(1:pi);
                    ti_dtm_actual.time = ti_track(1:pi,1);

                    % Consider only points after half track is observed
                    if (pi >= round(ti_len/2)+1)

                        % Compute expected DTM 
                        ti_dtm_expected = get_DTM_expected(data.trainSet{crowd_m}.DTM{ti_POI_pair_idx}, ti_track_mean_v(pi), config.delta_t);

                        % Compute actual area under the curve of track ti
                        ti_dtm_actual.auc = trapz(ti_dtm_actual.time(1:pi), ti_dtm_actual.dist(1:pi));

                        % Compute expected area under the curve of track ti
                        if (pi > ti_dtm_expected.len)
                            ti_dtm_expected.auc = trapz(ti_dtm_expected.time(1:ti_dtm_expected.len), ti_dtm_expected.dist(1:ti_dtm_expected.len));
                        else
                            ti_dtm_expected.auc = trapz(ti_dtm_expected.time(1:pi), ti_dtm_expected.dist(1:pi));
                        end

                        % Compute AUC difference 
                        dif_auc = ti_dtm_expected.auc - ti_dtm_actual.auc;   

                        % Delta dtm should be in [-1, 1]
                        delta_dtm = (dif_auc/ti_dtm_expected.auc);
                        delta_dtm(delta_dtm < -1) = -1;
                        delta_dtm(delta_dtm > 1) = 1;

                        % Compute emotional state
                        dataset.tracks_emotion_est{ti}(pi) = data.trainSet{crowd_m}.EMOTION.expected_emotion + (data.trainSet{crowd_m}.EMOTION.expected_emotion * delta_dtm); 
                    end 
                end
            end

            % If the POI pair is known and there is a DTM
            if (dataset.tracks_POI_pair(ti,3) ~= 0) && (~isempty(dataset.tracks_emotion_label{ti}))

                % Consider only points after half track is observed
                pi = round(ti_len/2)+1;
                pf = ti_len;

                % Compute Mean Square Error (MSE)
                dataset.tracks_emotion_mse(ti) = (1/(pf-pi)) * sum((dataset.tracks_emotion_label{ti}(pi:pf) - dataset.tracks_emotion_est{ti}(pi:pf)).^2);
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
clc; disp('Step 13.4: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 13: Done!');
