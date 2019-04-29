% DESCRIPTION: Compute the mean velocity of a track with regular intervals
%
% INPUT: track => sample points of track in x,y
%         delta_t => size of time interval
%
% OUTPUT: mean_v => mean velocity 

function mean_v = get_track_mean_v(track, delta_t)

    % Get size of track
    [ti_len, ~] = size(track);
    
    % Initialize velocity vector
    v = zeros(ti_len,1);
    
    % For each point of track ti
    for pi = 2:ti_len
        % Compute velocity
        v(pi) = sqrt((track(pi,1) - track(pi-1,1))^2 ...
            + (track(pi,2) - track(pi-1,2))^2) / delta_t;
    end
    
    % The velocity in pi = 1 is assumed to be the same as for pi=2
    v(1) = v(2);
            
    % Compute mean velocity
    mean_v = mean(v);
end

