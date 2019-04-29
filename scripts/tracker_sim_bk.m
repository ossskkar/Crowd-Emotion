% DESCRIPTION
% Simulates the information fed from a pedestrian tracker 

% Parameters
max_age = 4;

% Time range
time.start = min(dataset.raw(:,1));
time.end = max(dataset.raw(:,1));

net_size = length(TOPO_output.weight);

% Initialize tracks
tracks = [];

% State Vector 
sv.counting = []; 
sv.cos_sim = [];
sv.vx = [];
sv.vy = [];

% For each time instance
for t = time.start:time.end
    
    % Update message
    clc; disp(['Time: ', num2str(t)]); 
    
    % Obtain detected tracks
    tracks_id = unique(dataset.raw(find(dataset.raw(:,1) == t),2));
    
    % Fetch raw data
    data = dataset.raw(find(dataset.raw(:,1) == t),:);
    
    
    if (~isempty(data))
        
        % Update tracks list
        tracks = updateTrackList(tracks, tracks_id, max_age);
    
        % Update tracks data
        tracks = updateTrackData(tracks, tracks_id, dataset.tracks, t);
    
        % Compute state vector
        %state_vector;
    end
    
end
%{
% Normalize counting
minv = 0;
maxv = max(max(sv.counting));
sv.counting = (sv.counting - minv)./(maxv-minv);

% Normalize cosine similarity
minv = -1;
maxv = 1;
sv.cos_sim = (sv.cos_sim - minv)./(maxv-minv);

% Normalize velocity
minv = min(min(sv.vx));;
maxv = max(max(sv.vx));
sv.vx = (sv.vx - minv)./(maxv-minv);

minv = min(min(sv.vy));;
maxv = max(max(sv.vy));
sv.vy = (sv.vy - minv)./(maxv-minv);

% Unify state vector's features
sv.unified = [sv.counting sv.cos_sim, sv.vx, sv.vy];
%sv.unified = [sv.counting, sv.cos_sim];
%}

% Save data
%clc; disp('saving data'); 
%save ../data/PETS_sv sv;

% Clear workspace
%clear_workspace;
clear active_classes classes data dataset dp i idc idt j max_age...
      net_size new_counting new_cs t this_cs this_track time tracks...
      tracks_id maxv minv;

function tracks = updateTrackData(tracks, tracks_id, tracks_data, t)

    % For each new track id
    for i = 1:length(tracks_id)
        
        % Get track data
        new_data = tracks_data{tracks_id(i)};
        new_data_idx = find(new_data(:,1) == t);
       
        idx = find([tracks(:).id] == tracks_id(i));
        
        % Add data
        tracks(idx).data = [tracks(idx).data; new_data(new_data_idx,:)];
        
    end

end


function tracks = updateTrackList(tracks, tracks_id, max_age)

    % If list is empty
    if (isempty(tracks))
        
        % Initialize list
        tracks = newTrack(tracks, tracks_id);
       
        return;
    end
        
    % Get indexes of missing / previous / new tracks
    new_ids  = setdiff(tracks_id, [tracks(:).id]);
    miss_ids = setdiff([tracks(:).id], tracks_id);
    exist_ids = intersect([tracks(:).id], tracks_id);
        
    % New tracks
    tracks = newTrack(tracks, new_ids);
    
    % Existing tracks
    tracks = existTrack(tracks, exist_ids);
    
    % Missing tracks
    tracks = missTrack(tracks, miss_ids, max_age);
        
end


function tracks = newTrack(tracks, new_ids)

    % Add new tracks
    for i = 1:length(new_ids)
        new_track.id = new_ids(i);
        new_track.age = 0;
        new_track.active = 1;
        new_track.data = [];
        
        tracks = [tracks; new_track];
    end
end


function tracks = existTrack(tracks, exist_ids)
    
    % For each existing id
    for i = 1:length(exist_ids)
        % reset age
        idx = find([tracks(:).id] == exist_ids(i));
        tracks(idx).age = 0;
    end
end


function tracks = missTrack(tracks, miss_ids, max_age)
    
    % For each missing id
    for i = 1:length(miss_ids)
            
        % Update age
        idx = find([tracks(:).id] == miss_ids(i));
        tracks(idx).age = tracks(idx).age + 1;
            
        % Deactivate tracks older than max_age
        if (tracks(idx).age > max_age)
            tracks(idx).active = 0;
        end 
    end
end

