function data = getSimIndex(data)

% DESCRIPTION: given a set of tracks, compute the heading (in degrees) for
%              each track at every time instant.


% COMPUTE HEADING (DEGREES)

% Get number of tracks
ntracks = length(data.tracks);

% For each track compute [vx vy v]
for i = 1:ntracks

    % Update status
    display(strcat('Processing track #', num2str(i)));

    % Get current track
    this_track = data.tracks{i};

    % Get size of track
    [n, ~] = size(this_track);

    % Initialize heading vectors
    h = zeros(n,1); % heading 

    u = [1 0 0]; % Unit vector in positive x-axis
    
    % Consider only tracks with more than 1 sample point
    if (n > 1)
        for j = 2:n
            
            % Get heading vector at row j [x y z]
            v = [this_track(j,4) this_track(j,5) 0];
            
            % Get angle at row j
            h(j,1) = round(atan2d(norm(cross(u,v)),dot(u,v)));
            
            % Convert angle to 360
            if (v(2) < 0)
                h(j,1) = 360 - h(j,1);
            end
            
        end
        
        % Assume first and second point have same heading
        h(1) = h(2);
    end

    % Update track
    data.tracks{i}(:,7) = h;

    % Find rows index of track i
    idx_track = data.raw(:,2) == i;
    
    % Update heading 
    data.raw(idx_track,8) = h;
    
end


% COMPUTE SIMILARITY VECTOR

% Get time vector
t = unique(data.raw(:,1));

% Initialize similarity vector
cs = zeros(length(t),2);
cs(:,1) = t;

for i = 2:length(t)
    
    % Update status
    display(strcat('Processing time t=', num2str(t(i))));
    
    % Get index and data of rows at time t
    idx_rows = data.raw(:,1) == t(i);
    data_rows = data.raw(idx_rows,:);
    
    % Get index of tracks active at time t
    idx_tracks = unique(data_rows(:,2));
    
    if (length(idx_tracks) > 1)
        % Get pair combination of all active tracks
        % c = [track_a_id track_b_id Ax Ay Bx By CosSim]
        c = nchoosek(idx_tracks,2);

        [n_c ~] = size(c);
        
        % For each pair in c
        for j = 1:n_c

            % Get vector a
            idx_track_row = data_rows(:,2) == c(j,1);
            c(j,3:4) = data_rows(idx_track_row,5:6);

            % Get vector b
            idx_track_row = data_rows(:,2) == c(j,2);
            c(j,5:6) = data_rows(idx_track_row,5:6);

            % Compute cosine similarity between vector a and b
            c(j,7) = (dot(c(j,3:4),c(j,5:6))) / (norm(c(j,3:4))*norm(c(j,5:6)));

            %if isnan(c(j,7))
            %    c(j,7) = 
            %end


        end

        c(isnan(c(:,7)),:) = [];

        cs(i,2) = mean(c(:,7));
    else
        % Index is 1 one only one track is active
        cs(i,2) = 1;
    end
end

% Normalize similarity index, min_v = -1, max_v = 1
cs(:,2) = (cs(:,2)+1)./(1+1);

% Compute global mean similarity
cs(:,3) = mean(cs(:,2));

% Update data
data.sim_index = cs;

end