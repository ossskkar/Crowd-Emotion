% DESCRIPTION: Compute the distance to motivation at each time t
% 
% IMPORTANT: This only works if the whole track is already observed***

function track_dist_to_motivation = get_track_dist_to_motivation(track, track_len)

    % Initialize track_dist 
    track_dist_to_motivation = zeros(track_len,1);

    % For each point
    for pi = 1:track_len

        % Add the distance travel between point pi and last point pi+n
        track_dist_to_motivation(pi) = sqrt((track(pi,1) - track(track_len,1))^2 + (track(pi,2) - track(track_len,2))^2); 
    end 
end