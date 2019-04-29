function data = getAvgSpeed(data)

% DESCRIPTION: given a set of tracks, compute the speed components for each
%              track.

% Get number of tracks
ntracks = length(data.tracks);

% For each track compute [vx vy v]
for i = 1:ntracks

    % Update status
    display(strcat('Processing track #', num2str(i)));

    % Get current track
    this_track = data.tracks{i}(:,1:3);

    % Get size of track
    [n, ~] = size(this_track);

    % Initialize speed vectors
    v = zeros(n,3); % [vx vy v]

    % Consider only tracks with more than 1 sample point
    if (n > 1)

        % Start from the second sample point
        for j = 2:n
            v(j,1) = (this_track(j,2) - this_track(j-1,2))/(this_track(j,1) - this_track(j-1,1)) ; % vx
            v(j,2) = (this_track(j,3) - this_track(j-1,3))/(this_track(j,1) - this_track(j-1,1)) ; % vy
            v(j,3) = sqrt(v(j,1)^2 + v(j,2)^2); % v
        end
        
        % Assume speed at t=1 is same as t=2
        v(1,:) = v(2,:);
    end

    % Update tracks
    data.tracks{i} = [this_track v.*data.inf.meter_per_pixel];

    % Update data
    idx_track = data.raw(:,2) == i;
    data.raw(idx_track,5:7) = v;
    
end


% Get time vector
t = unique(data.raw(:,1));

% Initialize average speed vectors
av = zeros(length(t),4); % [t avx avy av]

% update time 
av(:,1) = t;

% Compute average speed at each time t
for i = 1:length(t)

    % Update status
    display(strcat('Computing average speed at time t=', num2str(t(i))));

    % Find data rows at time t(i)
    idx_rows = data.raw(:,1) == t(i);

    % Find all tracks at time t(i)
    idx_tracks = data.raw(idx_rows,2);

    % Counter for number of tracks with speed at time t(i)
    ntracks = 0;

    % For each track
    for j = 1:length(idx_tracks)

        % Get current track
        this_track = data.tracks{idx_tracks(j)};

        % Find row index at time t(i)
        idx_track_row = find(this_track(:,1) == t(i));

        % Except for first row of track, all should be included for average 
        % speed 
        %if (idx_track_row > 1)

            % Update track counter
            ntracks = ntracks + 1;

            % Sum speed of this track
            av(i,2:4) = av(i,2:4) + this_track(idx_track_row,4:6);

        %end
    end

    % Get average speed for all components
    av(i,2:4) = av(i,2:4)./ ntracks;

end

% Update average speed
data.avg_speed = av;

end
