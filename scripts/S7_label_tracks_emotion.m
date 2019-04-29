% DESCRIPTION: Compute emotion labels for tracks in train and test sets

% Clean up
clear; close all; clc;
clc; disp('Step 7.1: Clean up'); 

% Load data
clc; disp('Step 7.2: Load data'); 
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

        DTM = data.trainSet{set_i}.DTM; % Because only train sets have DTMs
        
        % STEP #1: Compute emotion labels for tracks
        
        % Emotional state parameters
        dataset.EMOTION= config.EMOTION{set_i};
        
        % Initialize variables
        dataset.tracks_emotion_label = {};

        % For each POI pair
        for pai = 1:data.POI.pairs_len

            % Get indexes of tracks in this path origin-dest pair
            pa_tracks_idx = find(dataset.tracks_POI_pair(:,3) == pai);
            pa_tracks_len = length(pa_tracks_idx);

            % For each track
            for ti = 1:pa_tracks_len

                % Update status
                disp(strcat('Step 7.3: Processing pair-', num2str(pai), '-track #',num2str(ti)));

                % Get original data from track
                ti_track = [];
                ti_track(:,2:3) = dataset.tracks{pa_tracks_idx(ti)}(:,2:3);
                [ti_len, ~] = size(ti_track);

                % Consider only tracks with more than one sample
                if (ti_len > 1) && (~isempty(DTM{pai}.len))

                    % Convert time to seconds 
                    % ** IMPORTANT: dont take the dataset's timestamp, instead 
                    % assign time as some tracks (ex: ti = 10096) have missing lapses of time **
                    %ti_track(:,1) = (ti_track(:,1)-ti_track(1,1))./fps;
                    ti_track(:,1) = (0:config.delta_t:config.delta_t*(ti_len-1)); 

                    track_dist = get_track_dist_to_motivation(ti_track(:,2:3), ti_len);

                    % Adjust DTM to to this track
                    %dtm_adjusted = get_DTM_adjusted(ti_track, config.delta_t, DTM{pai}.track_dist(ti,1), DTM{pai});
                    dtm_adjusted = get_DTM_adjusted(ti_track, config.delta_t, track_dist(1), DTM{pai});

                    % Initialize variables for area under the curve
                    ti_auc = zeros(max([ti_len, dtm_adjusted.len]),1);
                    dtm_adjusted.auc = zeros(max([ti_len, dtm_adjusted.len]),1);
                    % For each point of track ti
                    for pi = 2:max([ti_len, dtm_adjusted.len])

                        % Compute partial area under the curve of track ti
                        if (ti_len >=pi)
                            %ti_auc_cumulative(pi) = trapz(ti_track(1:pi,1), DTM{pai}.track_dist(ti,1:pi));
                            ti_auc(pi) = trapz(ti_track(1:pi,1), track_dist(1:pi));
                        else
                            ti_auc(pi) = ti_auc(pi-1);
                        end

                        % Compute partial area under the curve of dtm cumulative
                        if (dtm_adjusted.len >=pi)
                            
                            % Compute area under the curve for expected dtm
                            dtm_adjusted.auc(pi) = trapz(dtm_adjusted.time(1:pi), dtm_adjusted.dist(1:pi));
                        else
                            dtm_adjusted.auc(pi) = dtm_adjusted.auc(pi-1);
                        end
                    end

                    % Delta dtm should be in [-1, 1]
                    delta_dtm = ((dtm_adjusted.auc - ti_auc)./dtm_adjusted.auc);
                    delta_dtm(delta_dtm < -1) = -1;
                    delta_dtm(delta_dtm > 1) = 1;

                    % Compute emotional state
                    new_emotion = dataset.EMOTION.expected_emotion + (dataset.EMOTION.tolerance * dataset.EMOTION.expected_emotion * delta_dtm);
                    %new_emotion = 1 - delta_dtm;
                    new_emotion(1) = new_emotion(2);
                    dataset.tracks_emotion_label{pa_tracks_idx(ti)} = new_emotion;
                end
            end
        end
        
        % STEP #2: Compute mean emotion per zone

        % Get timestamps of all data
        t_original = unique(dataset.raw(:,1));
        
        % Initialize mean emotion per zone
        dataset.mean_emotion_per_zone = zeros(length(t_original), data.TOPO.n_neurons);

        % Cluster data 
        c = net_cluster(data.TOPO.output.weight, dataset.raw(:,3:4));

        % For each zone zi
        for zi = 1:data.TOPO.n_neurons
            
            % Find index of data for zone zi
            zi_idx = find(c == zi);

            % Get data for zone zi
            zi_data = dataset.raw(zi_idx,:);

            % Get timestamps of only data for zi
            t = unique(zi_data(:,1));

            % For each time t
            for ti = 1:length(t)

                % Update status
                disp(['Step 7.4: Processing zone ', num2str(zi), ', time ', num2str(ti)]); 

                % Initialize counter
                ti_counter = 0;

                % Find active tracks at time t
                ti_data_idx = find(zi_data(:,1) == t(ti));

                % Get index of active tracks
                at_idx = zi_data(ti_data_idx,2);

                % Do only if any active tracks found
                if (~isempty(at_idx))

                    % For each active track
                    for ati = 1:length(at_idx)

                        if at_idx(ati) < length(dataset.tracks_emotion_label)
                            ri = find(dataset.tracks{at_idx(ati)}(:,1)== t(ti));

                            if (~isempty(dataset.tracks_emotion_label{at_idx(ati)}) && ~isempty(ri))

                                ti_original = find(t_original == t(ti));
                                
                                % Accumulate emotion
                                dataset.mean_emotion_per_zone(ti_original,zi) = dataset.mean_emotion_per_zone(ti_original,zi) ...
                                    + dataset.tracks_emotion_label{at_idx(ati)}(ri);

                                % Update counter
                                ti_counter = ti_counter + 1;
                            end
                        end
                    end

                    % Compute mean 
                    if (ti_counter > 0)
                        dataset.mean_emotion_per_zone(ti_original,zi) = dataset.mean_emotion_per_zone(ti_original,zi) / ti_counter;
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
clc; disp('Step 7.5: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 7: Done!');
