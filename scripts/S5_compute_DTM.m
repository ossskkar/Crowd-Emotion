% DESCRIPTION: Compute mean DTM (Distance to Motivation)

% Clean up
clear; close all; clc;
clc; disp('Step 5.1: Clean up'); 

% Load data
clc; disp('Step 5.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% For each training set
for set_i = 1:length(data.trainSet)

    % Use dataset set_i
    dataset = data.trainSet{set_i};

    % Initialize DTM 
    dataset.DTM = cell(data.POI.pairs_len,1);

    % Compute the length of each track
    each_track_len = zeros(dataset.tracks_len,1);
    for ti = 1:dataset.tracks_len
        [each_track_len(ti), ~] = size(dataset.tracks{ti});
    end

    % For each path origin-dest pair
    for pai = 1:data.POI.pairs_len

        % Get indexes of tracks in this path origin-dest pair
        pa_tracks_idx = find(dataset.tracks_POI_pair(:,3) == pai);
        pa_tracks_len = length(pa_tracks_idx);

        dataset.DTM{pai}.len = max(each_track_len(pa_tracks_idx));

        track_dist_temp{pai} = zeros(pa_tracks_len, dataset.DTM{pai}.len);
        track_time_temp{pai} = zeros(pa_tracks_len, dataset.DTM{pai}.len);

        % For each track
        for ti = 1:pa_tracks_len

            % Update status
            clc; disp(strcat('Step 5.3: Processing pair-', num2str(pai), '-track #',num2str(ti)));

            % Track ti
            ti_track = dataset.tracks{pa_tracks_idx(ti)}(:,2:3);
            [ti_len, ~] = size(ti_track);

            % Get distance to motivation at every time t
            track_dist_temp{pai}(ti,1:ti_len) = get_track_dist_to_motivation(ti_track, ti_len);

        end

        % Normalize time 
        for ti = 1:pa_tracks_len

            % Get size of track
            [ti_len, ~] = size(dataset.tracks{pa_tracks_idx(ti)}(:,1));

            % Set original time domain, ti_len-1 because time starts at 0
            track_time_temp{pai}(ti,1:ti_len) = 0:config.delta_t:config.delta_t*(ti_len-1);

            % Normalize time domain according to max length (rounded to two decimal positions)
            track_time_temp{pai}(ti,1:ti_len) = round(track_time_temp{pai}(ti,1:ti_len) .* (dataset.DTM{pai}.len/ti_len),2);

            % Round time to uniform spaced intervals of delta_t
            track_time_temp{pai}(ti,1:ti_len) = round(track_time_temp{pai}(ti,1:ti_len)./config.delta_t) .* config.delta_t;
        end

        % Convert (temporarily) the time to integer for convenience 
        % because 'find' cant be used with decimal values
        track_time_temp{pai} = int32(track_time_temp{pai}.*100);

        dataset.DTM{pai}.track_dist = track_dist_temp{pai};

        % Initialize time line
        dataset.DTM{pai}.track_time = int32((0:config.delta_t:config.delta_t*dataset.DTM{pai}.len)*100);
        dataset.DTM{pai}.track_dist_normalized = zeros(pa_tracks_len,dataset.DTM{pai}.len);

        % For each track
        for ti = 1:pa_tracks_len

            % For each time instant
            for dti = 1:dataset.DTM{pai}.len

                % Update status
                disp(strcat('Step 5.4: Processing pair-', num2str(pai), '-time-', num2str(dti), '-track #',num2str(ti)));

                % Get the current time
                dti_t = dataset.DTM{pai}.track_time(dti);

                % Check if there is a sample at time dti
                dti_idx = find(track_time_temp{pai}(ti,:) >= dti_t);

                % If there is sample at dti
                if (~isempty(dti_idx))

                    % Check if is the first sample and if the track is longer
                    % than one sample
                    if ((dti_t == 0) || (track_time_temp{pai}(ti,dti_idx(1)) == dti_t))

                        % Assign distance from original data
                        dataset.DTM{pai}.track_dist_normalized(ti,dti) = track_dist_temp{pai}(ti,dti_idx(1));

                    elseif  (track_time_temp{pai}(ti,dti_idx(1)) ~= 0)

                        % Compute distance difference
                        dist_delta = (track_dist_temp{pai}(ti,dti_idx(1)) - track_dist_temp{pai}(ti,dti_idx(1)-1));

                        % Compute time proportion
                        time_proportion = double(dti_t - track_time_temp{pai}(ti,dti_idx(1)-1)) / double(track_time_temp{pai}(ti,dti_idx(1)) ...
                            - track_time_temp{pai}(ti,dti_idx(1)-1));

                        % Compute distance at time dti
                        dataset.DTM{pai}.track_dist_normalized(ti,dti) = track_dist_temp{pai}(ti,dti_idx(1)-1) + dist_delta * time_proportion;
                    end
                end
            end
        end

        dataset.DTM{pai}.track_time = zeros(pa_tracks_len, dataset.DTM{pai}.len);

        % For each track
        for ti = 1:pa_tracks_len    

            % Update status
            disp(strcat('Step 5.5: Process track-',num2str(ti))); 

            % Get size of track
            [ti_len, ~] = size(dataset.tracks{pa_tracks_idx(ti)}(:,1));

            % restore time line to original values
            dataset.DTM{pai}.track_time(ti,1:ti_len) = round((0:config.delta_t:config.delta_t*(ti_len-1)) .* (dataset.DTM{pai}.len/ti_len),2);
        end 

        % Update status
        disp(strcat('Step 5.6: Compute mean DTM for pair-',num2str(pai))); 

        % Compute mean distance and time
        if (pa_tracks_len > 1)
            dataset.DTM{pai}.mean_dist = mean(dataset.DTM{pai}.track_dist_normalized);
            dataset.DTM{pai}.mean_time = 0:config.delta_t:config.delta_t*(dataset.DTM{pai}.len-1);
        elseif (pa_tracks_len == 1)
            dataset.DTM{pai}.mean_dist = dataset.DTM{pai}.track_dist_normalized;
            dataset.DTM{pai}.mean_time = 0:config.delta_t:config.delta_t*(dataset.DTM{pai}.len-1);
        end
        
        % Update status
        disp(strcat('Step 5.7: Compute standard deviation DTM for pair-',num2str(pai))); 
        
        pai_std = zeros(dataset.DTM{pai}.len,1);
        
        % For each time instance
        for pi = 1:dataset.DTM{pai}.len
        
            % Compute standard deviation
            pai_std(pi) = std(dataset.DTM{pai}.track_dist_normalized(:,pi));
        end
        
        % Compute mean standard deviation
        dataset.DTM{pai}.std = mean(pai_std);
    end
    
    % Update dataset set_i
    data.trainSet{set_i} = dataset;
end

% Save data
clc; disp('Step 5.8: Save data'); 
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 5: Done!');
