% DESCRIPTION: Estimate emotion of tracks in dataset by
%              
%              STEP #1 - Take the motivation estimated from 'eval_tracks_motivation'
%              STEP #2 - Estimate desired walking speed
%              STEP #3 - Generate expectation
%              STEP #4 - Estimate emotion

% Clean up
disp('Cleaning up');
clear; close all; clc;

% Parameters
file_names.attractors_file = 'attractors_cstation_cvpr2015';
file_names.motivation_file = 'cstation_cvpr2015_eval_half_no_sw'; % data and motivation estimation is included here
file_names.emotion_file    = 'emotion_cstation_cvpr2015';
file_names.img_file        = 'cstation_cvpr2015.jpg';

% Load data
disp('Loading data');
load(strcat('../data/', file_names.attractors_file));
load(strcat('../data/', file_names.motivation_file));
load(strcat('../data/', file_names.emotion_file));

% Parameters
delta_t = 0.64;

% Get total number of tracks
num_tracks = length(data.tracks);

ti_init = 1;
ti_final = num_tracks;


% STEP #1 - Estimate desired walking speed 

% For each track
for ti = ti_init:ti_final
    
    % Update status
    disp(strcat('STEP #1 - Processing track #',num2str(ti)));
    
    % Ge track data
    ti_track = [];
    ti_track(:,2:3) = data.tracks{ti}(:,2:3);
    [ti_len, ~] = size(ti_track);
    ti_track(:,1) = (0:delta_t:delta_t*(ti_len-1)); % timestamp is manualy computed
    
    % Initialize vector for computing walking speed
    ti_v = zeros(ti_len,1);
    ti_estimated_v0 = zeros(ti_len,1);
    
    % For each point
    for pi = 2:ti_len
        
        % Compute walking speed
        ti_v(pi) = sqrt((ti_track(pi-1,2) - ti_track(pi,2))^2 + (ti_track(pi-1,3) - ti_track(pi,3))^2) / delta_t;
        
        % Compute mean walking speed at every point
        ti_estimated_v0(pi) = mean(ti_v(2:pi));
    end
    
    % Update data
    emotion.track_estimated_v0{ti} = ti_estimated_v0;
    emotion.track_v{ti} = ti_v;
end


% STEP #2 - Compute predicted emotion

% For each track
for ti = ti_init:ti_final
    
    % Update status
    disp(strcat('STEP #2 - Processing track #',num2str(ti)));
    
    % Ge track data
    ti_track = [];
    ti_track(:,2:3) = data.tracks{ti}(:,2:3);
    [ti_len, ~] = size(ti_track);
    ti_track(:,1) = (0:delta_t:delta_t*(ti_len-1)); % timestamp is manualy computed
    
    % Get attractor of origin and destination estimations
    ti_origin = emotion.track_origin_dest_attr(ti,1);
    ti_dest = data.tracks_prediction{ti};
    
    % Get the prototype track to all possible attractors
    proto_tracks = get_proto_tracks(ti_track(1,2:3),attractors.groundtruth);
    
    % Initialize vector for path idexes from predicted destination
    pai = zeros(ti_len,1);
    emotion.emotion_predicted{ti} = zeros(ti_len,1);
    
    % For each point (starting after half of the track)
    for pi = (round(ti_len/2)+1):ti_len
    
    % For each point
    %for pi = 1:ti_len
        
        % Get path index
        new_pai = find(ismember(emotion.paths_origin_dest, [ti_origin ti_dest(pi)], 'rows'));
        
        % If this is a valid path
        if (any(new_pai))
            
            % Update path index
            pai(pi) = new_pai;
            
            % Get last point of prototype track of attractor ti_dest(pi)
            proto_len = length(proto_tracks{ti_dest(pi)}(:,1));
            pf = proto_tracks{ti_dest(pi)}(proto_len,:);
            
            % Get distance to motivation 
            ti_dtm = sqrt((pf(1) - ti_track(1,1))^2 + (pf(2) - ti_track(1,2))^2);
            
            % Compute DTM histogram from point 1 to pi
            ti_dtm_hist = sqrt((pf(1) - ti_track(1:pi,2)).^2 + (pf(2) - ti_track(1:pi,3)).^2);
            
            % Get expected DTM histogram
            dtm_hist = get_dtm_hist_adjusted(ti_track(1:pi,:), delta_t, ti_dtm, emotion, pai(pi));

            if (~isempty(dtm_hist))
                % Compute actual area under the curve of track ti
                ti_auc_cumulative = trapz(ti_track(1:pi,1), ti_dtm_hist(1:pi));

                % Compute expected area under the curve of track ti
                if (pi > dtm_hist.len)
                    dtm_hist.auc_cumulative = trapz(dtm_hist.time(1:dtm_hist.len), dtm_hist.dist(1:dtm_hist.len));
                else
                    dtm_hist.auc_cumulative = trapz(dtm_hist.time(1:pi), dtm_hist.dist(1:pi));
                end

                % Compute AUC difference (cumulative)
                dif_auc_cumulative = dtm_hist.auc_cumulative - ti_auc_cumulative;   

                % Delta dtm should be in [-1, 1]
                delta_dtm = (dif_auc_cumulative/dtm_hist.auc_cumulative);
                delta_dtm(delta_dtm < -1) = -1;
                delta_dtm(delta_dtm > 1) = 1;

                % Compute emotional state
                emotion.emotion_predicted{ti}(pi) = emotion.expected_emotion + (emotion.expected_emotion * delta_dtm); 
            else
                % Compute emotional state
                emotion.emotion_predicted{ti}(pi) = 0;
            end
        end
    end 
end


% STEP #3: Compute emotion Mean Square Error (MSE)

% For each track
for ti = ti_init:ti_final
    
    % Update status
    disp(strcat('STEP #3 - Processing track #',num2str(ti)));
    
    % Ge track data
    ti_track = [];
    ti_track(:,2:3) = data.tracks{ti}(:,2:3);
    [ti_len, ~] = size(ti_track);
    ti_track(:,1) = (0:delta_t:delta_t*(ti_len-1)); % timestamp is manualy computed
   
    % Compute accuracy after half samples
    pi = round(ti_len/2) + 1;
    pf = ti_len;
    
    % Use only tracks with know origin and destination
    if (~isempty(emotion.emotion_cumulative{ti}))
        
        % Compute Mean Square Error (MSE)
        emotion.track_mse{ti} = (1/(pf-pi)) * sum((emotion.emotion_cumulative{ti}(pi:pf) - emotion.emotion_predicted{ti}(pi:pf)).^2);
    end
end


% STEP #4 - Compute Average MSE

num_tracks = length(emotion.emotion_cumulative);
n = 0;
emotion.mse = 0;
for ti = 1:num_tracks
    
    % Update status
    disp(strcat('STEP #4 - Processing track #',num2str(ti)));
    
    if (~isempty(emotion.track_mse{ti}) && ~isinf(emotion.track_mse{ti}) && ~isnan(emotion.track_mse{ti}))
        
        n = n + 1;
        emotion.mse = emotion.mse + emotion.track_mse{ti};
    end
end

emotion.mse = emotion.mse / n;


% Save data
save(strcat('../data/', file_names.emotion_file, '_eval_half_no_sw'), 'emotion');

% Update status
disp('Done!');
