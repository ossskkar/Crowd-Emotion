% DESCRIPTION: generate annotations of emotions for a given dataset

% Clean up
close all; clear; clc;

% Parameters
attractors_file = 'attractors_cstation_cvpr2015';
data_file = 'cstation_cvpr2015';
img_file = 'cstation_cvpr2015.jpg';

% Load data
disp('Loading data');
load(strcat('../data/',attractors_file));
load(strcat('../data/',data_file));

%Get number of tracks
[track_len, ~] = size(data.tracks);

% Get number of attractors
[~, attractor_len] = size(attractors.groundtruth);

% Initialize variables
track_attractors = zeros(track_len,2);
dist_treshold = 6;

fps = 25 * 1.25; % frames per second * frames per second annotated
delta_t = 0.64;

% STEP 1: GET ORIGIN-DESTINATION ATTRACTORS
%{
% For each track
for ti = 1:track_len
    
    % Update status
    disp(strcat('Processing track #',num2str(ti)));
    
    % Get track ti
    ti_track = data.tracks{ti}(:,2:3);
    
    % Get track lenght
    [ti_len, ~] = size(ti_track);
    
    % Origen and destination attractors with minimum distance to initial
    % and final point to track ti
    min_attr_origin_dist = 0;
    min_attr_dest_dist   = 0;
    
    % for each attractor
    for ai = 1:attractor_len
        
        % Compute the minimum distance between initial point and attractor points
        ai_dist = min(pdist2(ti_track(1,:),attractors.groundtruth{ai}.p));
        
        % Check if attractor ai is the closest to initial point of track ti
        if (ai_dist < dist_treshold)
            track_attractors(ti,1) = ai;
            min_attr_origin_dist = ai_dist;
        end
        
        % Compute the minimum distance between final point and attractor points
        ai_dist = min(pdist2(ti_track(ti_len,:),attractors.groundtruth{ai}.p));
        
        % Check if attractor ai is the closest to final point of track ti
        if (ai_dist < dist_treshold)
            track_attractors(ti,2) = ai;
            min_attr_dest_dist = ai_dist;
        end
    end
end

emotion.track_origin_dest_attr = track_attractors;
%{%}

% STEP 2: ASSIGN A PATH LABEL BASED ON THE ORIGIN-DESTINATION PAIR
%{%}
paths_origin_dest = nchoosek(1:attractor_len,2);
paths_origin_dest = [paths_origin_dest; [paths_origin_dest(:,2), paths_origin_dest(:,1)]];

[pa_len, ~] = size(paths_origin_dest);

for pai = 1:pa_len
    [~, pa_idxs] = ismember(emotion.track_origin_dest_attr(:,1:2), paths_origin_dest(pai,:),'rows');
    
    emotion.track_origin_dest_attr(find(pa_idxs ~= 0),3) = pai;
end

emotion.paths_origin_dest = paths_origin_dest;
%}

% STEP 3: COMPUTE DISTANCE HISTOGRAM
%{
%load ../data/emotion_cstation_cvpr2015

% Compute the length of each track
each_track_len = zeros(track_len,1);
for ti = 1:track_len
    [each_track_len(ti), ~] = size(data.tracks{ti});
end

% Get number of path origin-dest pairs
[pa_len, ~] = size(emotion.paths_origin_dest);

% For each path origin-dest pair
for pai = 1:pa_len
    
    % Get indexes of tracks in this path origin-dest pair
    pa_tracks_idx = find(emotion.track_origin_dest_attr(:,3) == pai);
    pa_tracks_len = length(pa_tracks_idx);
    
    dist_hist_len = max(each_track_len(pa_tracks_idx));
    
    track_dist_temp{pai} = zeros(pa_tracks_len, dist_hist_len);
    track_time_temp{pai} = zeros(pa_tracks_len, dist_hist_len);
    
    % For each track
    for ti = 1:pa_tracks_len
        
        % Update status
        disp(strcat('Processing pair-', num2str(pai), '-track #',num2str(ti)));
        
        % Track ti
        ti_track = data.tracks{pa_tracks_idx(ti)}(:,2:3);
        [ti_len, ~] = size(ti_track);
        
        % For each point
        for pi = 2:ti_len

            % Add the distance travel between point pi and last point pi+n
            track_dist_temp{pai}(ti,pi-1) = sqrt((ti_track(pi-1,1) - ti_track(ti_len,1))^2 + (ti_track(pi-1,2) - ti_track(ti_len,2))^2); 
        end 
    end
    
    % Normalize time 
    for ti = 1:pa_tracks_len
        
        % Get size of track
        [ti_len, ~] = size(data.tracks{pa_tracks_idx(ti)}(:,1));
        
        % Set original time domain, ti_len-1 because time starts at 0
        track_time_temp{pai}(ti,1:ti_len) = 0:delta_t:delta_t*(ti_len-1);
        
        % Normalize time domain according to max length (rounded to two decimal positions)
        track_time_temp{pai}(ti,1:ti_len) = round(track_time_temp{pai}(ti,1:ti_len) .* (dist_hist_len/ti_len),2);
        
        % Round time to uniform spaced intervals of delta_t
        track_time_temp{pai}(ti,1:ti_len) = round(track_time_temp{pai}(ti,1:ti_len)./delta_t) .* delta_t;
        
    end
    
    % Convert (temporarily) the time to integer for convenience 
    % because 'find' cant be used with decimal values
    track_time_temp{pai} = int32(track_time_temp{pai}.*100);
    
    emotion.track_data{pai} = track_dist_temp{pai};
    
    % Initialize time line
    emotion.track_time{pai} = int32((0:delta_t:delta_t*dist_hist_len)*100);
    emotion.track_dist{pai} = zeros(pa_tracks_len,dist_hist_len);
    
    % For each track
    for ti = 1:pa_tracks_len
        
        % For each time instant
        for dti = 1:dist_hist_len
    
            % Update status
            disp(strcat('Processing pair-', num2str(pai), '-time-', num2str(dti), '-track #',num2str(ti)));
            
            % Get the current time
            dti_t = emotion.track_time{pai}(dti);
            
            % Check if there is a sample at time dti
            dti_idx = find(track_time_temp{pai}(ti,:) >= dti_t);
            
            % If there is sample at dti
            if (~isempty(dti_idx))
                
                % Check if is the first sample and if the track is longer
                % than one sample
                if ((dti_t == 0) || (track_time_temp{pai}(ti,dti_idx(1)) == dti_t))
                    
                    % Assign distance from original data
                    emotion.track_dist{pai}(ti,dti) = track_dist_temp{pai}(ti,dti_idx(1));
                    
                elseif  (track_time_temp{pai}(ti,dti_idx(1)) ~= 0)
                    
                    % Compute distance difference
                    dist_delta = (track_dist_temp{pai}(ti,dti_idx(1)) - track_dist_temp{pai}(ti,dti_idx(1)-1));
                    
                    % Compute time proportion
                    time_proportion = double(dti_t - track_time_temp{pai}(ti,dti_idx(1)-1)) / double(track_time_temp{pai}(ti,dti_idx(1)) ...
                        - track_time_temp{pai}(ti,dti_idx(1)-1));
                                        
                    % Compute distance at time dti
                    emotion.track_dist{pai}(ti,dti) = track_dist_temp{pai}(ti,dti_idx(1)-1) + dist_delta * time_proportion;
                end
            end
        end
    end
    
    emotion.track_time{pai} = zeros(pa_tracks_len, dist_hist_len);
    % For each track
    for ti = 1:pa_tracks_len    
        
        % Get size of track
        [ti_len, ~] = size(data.tracks{pa_tracks_idx(ti)}(:,1));
        
        % restore time line to original values
        emotion.track_time{pai}(ti,1:ti_len) = round((0:delta_t:delta_t*(ti_len-1)) .* (dist_hist_len/ti_len),2);
    end 
    
    % Compute mean distance and time of histogram
    if (pa_tracks_len > 1)
        emotion.dist_hist{pai} = mean(emotion.track_dist{pai});
        emotion.dist_time{pai} = 0:delta_t:delta_t*(dist_hist_len-1);
    elseif (pa_tracks_len == 1)
        emotion.dist_hist{pai} = emotion.track_dist{pai};
        emotion.dist_time{pai} = 0:delta_t:delta_t*(dist_hist_len-1);
    end
end
%}

% STEP 4: COMPUTE THE EMOTION FOR TRACKS
%{%}

load ../data/emotion_cstation_cvpr2015 emotion;

% Get number of path origin-dest pairs
[pa_len, ~] = size(emotion.paths_origin_dest);

emotion.emotion_cumulative = {};

for pai = 2%1:pa_len
    
    % Get indexes of tracks in this path origin-dest pair
    pa_tracks_idx = find(emotion.track_origin_dest_attr(:,3) == pai);
    pa_tracks_len = length(pa_tracks_idx);
    
    % For each track
    for ti = 1%1:pa_tracks_len

        % Update status
        disp(strcat('Processing pair-', num2str(pai), '-track #',num2str(ti)));
        
        ti_track = [];
        
        % Get original data from track
        %ti_track(:,1) = data.tracks{pa_tracks_idx(ti)}(:,1);
        ti_track(:,2:3) = data.tracks{pa_tracks_idx(ti)}(:,2:3);
        [ti_len, ~] = size(ti_track);
        
        % Consider only tracks with more than one sample
        if (ti_len > 1)

            % Convert time to seconds 
            % ** IMPORTANT: dont take the dataset's timestamp, instead 
            % assign time as some tracks (ex: ti = 10096) has missing lapses of time **
            %ti_track(:,1) = (ti_track(:,1)-ti_track(1,1))./fps;
            ti_track(:,1) = (0:0.64:0.64*(ti_len-1)); 

            dtm_hist = get_dtm_hist_adjusted(ti_track, delta_t, emotion.track_data{pai}(ti,1), emotion, pai);
            
            % Initialize variables for area under the curve
            ti_auc_cumulative = zeros(max([ti_len, dtm_hist.len]),1);
            dtm_hist.auc_cumulative = zeros(max([ti_len, dtm_hist.len]),1);
            
            % For each point of track ti
            for pi = 2:max([ti_len, dtm_hist.len])
                
                % Compute partial area under the curve of track ti
                if (ti_len >=pi)
                    ti_auc_cumulative(pi) = trapz(ti_track(1:pi,1), emotion.track_data{pai}(ti,1:pi));
                else
                    ti_auc_cumulative(pi) = ti_auc_cumulative(pi-1);
                end
                
                % Compute partial area under the curve of dtm histogram (cumulative and instantaneous)
                if (dtm_hist.len >=pi)
                    dtm_hist.auc_cumulative(pi) = trapz(dtm_hist.time(1:pi), dtm_hist.dist(1:pi));
                else
                    dtm_hist.auc_cumulative(pi) = dtm_hist.auc_cumulative(pi-1);
                end
            end
            
            % Compute AUC difference (cumulative)
            dif_auc_cumulative = dtm_hist.auc_cumulative - ti_auc_cumulative;   
            
            
            figure;
            subplot(2,1,1)
            hold on
            stem(ti_track(1:pi,1), emotion.track_data{pai}(ti,1:pi), 'b');
            stem(dtm_hist.time(:), dtm_hist.dist(:),'g');
            hold off
            subplot(2,1,2)
            hold on
            stem(ti_auc_cumulative,'b')
            stem(dtm_hist.auc_cumulative,'g')
            hold off
            
            
            % Emotional state parameters
            emotion.expected_emotion = 0.5;
            emotion.valence_range = 1;
            
            % Delta dtm should be in [-1, 1]
            delta_dtm = (dif_auc_cumulative./dtm_hist.auc_cumulative);
            delta_dtm(delta_dtm < -1) = -1;
            delta_dtm(delta_dtm > 1) = 1;
            
            % Compute emotional state
            new_emotion = emotion.expected_emotion + (emotion.expected_emotion * delta_dtm);
            new_emotion(1) = new_emotion(2);
            emotion.emotion_cumulative{pa_tracks_idx(ti)} = new_emotion;
        end
    end
end
%}
% Save data
%save ../data/emotion_cstation_cvpr2015 emotion;
