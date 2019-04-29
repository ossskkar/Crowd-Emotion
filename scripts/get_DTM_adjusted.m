% DESCRIPTION: Adjust Distance-to-Motivation to a desired time expectation
%
% INPUT: track => trajectory to use to adjust histogram
%        delta_t => time interval 
%        dtm => the DTM to be adjusted

function dtm_adjusted = get_DTM_adjusted(track, delta_t, dtm, DTM)

    % Get track lenght
    [track_len, ~] = size(track);

    % Compute mean velocity
    track_mean_v = get_track_mean_v(track(:,2:3),delta_t);

    % Compute the expected time for ti (distance / mean velocity)
    track_exp_t = dtm / track_mean_v;

    % Get DTM data
    dtm_temp.dist = DTM.mean_dist;

    if (~isempty(DTM.mean_time))
    
        % Adjust time to expectation of track ti
        dtm_temp.time = DTM.mean_time .* (track_exp_t/DTM.mean_time(DTM.len));

        % For each point 
        for pi = 1:track_len

            % Find the closest point according to the timeline of the track
            [~, j] = min(abs(dtm_temp.time-track(pi,1)));

            % Update DTM
            dtm_adjusted.time(pi) = track(pi,1);
            dtm_adjusted.dist(pi) = dtm_temp.dist(j);
        end

        % Update size of DTM
        dtm_adjusted.len = length(dtm_adjusted.time);
    else
        dtm_adjusted = [];
    end
end