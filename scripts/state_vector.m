% DESCRIPTION 
% Obtain features for crowd's state vector
% Features:
%           sv.counting => People counting by zone
%           sv.cos_sim  => Cosine similarity by zone
%           sv.vx       => X velocity component by zone
%           sv.vy       => Y velocity component by zone

%********************* PEOPLE COUNTING BY ZONE %*********************

% initialize counting state vector
new_counting = zeros(1,net_size);

% Get cluster classes
classes = net_cluster(TOPO_output.weight, data(:,3:4));

% Update counting state vector
for i = 1:length(classes)
    new_counting(classes(i)) = new_counting(classes(i)) + 1;
end

% Add new counting to state vector
sv.counting = [sv.counting; new_counting];


%********************* COSINE (DIRECTION) SIMILARITY BY ZONE %*********************
%{%
%tracks_direction = zeros(length(tracks_id),1);

% Delta dp => p2 - p1
dp = zeros(length(tracks_id),2);

new_cs = zeros(1,net_size);
new_cs(new_cs(:) == 0) = NaN;

% For each detected track
for i = 1:length(tracks_id)
   
    % Get track data
    this_track = tracks(i).data;
    
    % Get data row at time 't'
    idt = find(this_track(:,1) == t);
    
    % Consider only tracks with more than one sample
    if (idt > 1)
        
        % Get dp = p2 - p1
        dp(i,:) = [(this_track(idt,2:3) - this_track(idt-1,2:3))];
        
    end
end

% Get active classes
active_classes = unique(classes);

% For each active class
for i = 1:length(active_classes)
    
    % Get index of tracks cluster in class 'i'
    idc = find(classes(:) == active_classes(i));
    
    % Initialize cosine similarity for this class
    this_cs = zeros(length(idc)-1, 1);
    
    % Get cosine similarity among all tracks in class 'i'
    for j = 1:(length(idc)-1)
        this_cs(j) = cos_sim(dp(idc(j),:), dp(idc(j+1),:));
    end

    % If only one track, assign exact similirity
    if (length(idc) == 1)
        this_cs(1) = 1;
    end
    
    % Remove empty rows
    this_cs(any(isnan(this_cs),2),:)=[];
    
    % If any tracks in this class
    if (~isempty(this_cs))
        % Obtain the mean of cosine similarity in tracks of this class
        new_cs(active_classes(i)) = mean(this_cs);
    else 
        % No tracks for this class
        new_cs(active_classes(i)) = NaN;
    end
end

% Add new cosine similarity to state vector
new_cs(isnan(new_cs(:))) = 0;
sv.cos_sim = [sv.cos_sim; new_cs];

%}%
%********************* VELOCITY BY ZONE %*********************
% vx = dx / dt
% vy = dy / dt
%{%
% Initialize  [vx, vy, class]
v_tracks = zeros(length(tracks_id),3);
new_vx = zeros(1,net_size);
new_vy = zeros(1,net_size);

% For each detected track
for i = 1:length(tracks_id)
   
    % Get track data
    this_track = tracks(i).data;
    
    % Get data row at time 't'
    idt = find(this_track(:,1) == t);
    
    % Consider only tracks with more than one sample
    if (idt > 1)
        
        % Calculate track velocity (vx vy)
        v_tracks(i,1:2) = (this_track(idt,2:3) - this_track(idt-1,2:3));
        
        % Get class
        v_tracks(i,3) = net_cluster(TOPO_output.weight, this_track(idt,2:3));
        
    end
end

% For each active class
for i = 1:length(active_classes)
    
    % Find index of tracks clustered to class 'i'
    idxs = find(v_tracks(:,3) == active_classes(i));
    
    if (idxs)
        % Get average velocity for tracks in class 'i'
        new_vx(1,i) = mean(v_tracks(idxs,1));
        new_vy(1,i) = mean(v_tracks(idxs,2));
    end
end

% Add new velocity to state vector
sv.vx = [sv.vx; new_vx];
sv.vy = [sv.vy; new_vy];

%}%
