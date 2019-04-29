% DESCRIPTION
% Simulates the information fed from a pedestrian tracker 

% Initialize tracks
tracks = [];

% For each time instant
for t = this_set.time_start:this_set.time_end
        
    % Update message
    clc; disp(['Set: ' num2str(i), ' Time: ', num2str(t), '/', num2str(this_set.time_end)]); 
        
    % Get indexes of data at time t
    this_idx = this_set.raw(:,1) == t;
        
    % Obtain detected tracks
    tracks_id = unique(this_set.raw(this_idx,2));
        
    % If any data
    if (~isempty(this_idx))
            
        % Initialize counting state vector
        new_counting = zeros(1,data.TOPO.n_neurons);
            
        % Initialize cosine similarity
        dp = zeros(length(tracks_id),2);
        new_cs = zeros(1,data.TOPO.n_neurons);
        new_cs(new_cs(:) == 0) = NaN;
            
        % Initialize  [vx, vy, class]
        v_tracks = zeros(length(tracks_id),3);
        new_vx = zeros(1,data.TOPO.n_neurons);
        new_vy = zeros(1,data.TOPO.n_neurons);

        % Get cluster classes
        classes = net_cluster(data.TOPO.output.weight, this_set.raw(this_idx,3:4));
            
        % Get active classes
        active_classes = unique(classes);
            
        % For each class, update counting state vector
        for j = 1:length(classes)
            new_counting(classes(j)) = new_counting(classes(j)) + 1;
        end
 
        % For each detected track
        for k = 1:length(tracks_id)

            % Get track data
            this_track = this_set.tracks{tracks_id(k)};

            % Get data row at time 't'
            idt = find(this_track(:,1) == t);
                
            % Consider only tracks with more than one sample
            if (idt > 1)

                % Get dp = p2 - p1
                dp(k,:) = [(this_track(idt,2:3) - this_track(idt-1,2:3))];

                % Calculate track velocity (vx vy)
                v_tracks(k,1:2) = (this_track(idt,2:3) - this_track(idt-1,2:3));

                % Get class
                v_tracks(k,3) = net_cluster(data.TOPO.output.weight, this_track(idt,2:3));
                    
            end     
        end
            
        % For each active class
        for k = 1:length(active_classes)

            % Get index of tracks cluster in class 'i'
            idc = find(classes(:) == active_classes(k));
                
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
                new_cs(active_classes(k)) = mean(this_cs);
            else 
                % No tracks for this class
                new_cs(active_classes(k)) = NaN;
            end

            if (idc)
                % Get average velocity for tracks in class 'i'
                new_vx(1,k) = mean(v_tracks(idc,1));
                new_vy(1,k) = mean(v_tracks(idc,2));
            end
        end

        % Add new counting to state vector
        this_set.SV.counting = [this_set.SV.counting; new_counting];
            
        % Add new cosine similarity to state vector
        new_cs(isnan(new_cs(:))) = 0;
        this_set.SV.cos_sim = [this_set.SV.cos_sim; new_cs];
            
        % Add new velocity to state vector
        this_set.SV.vx = [this_set.SV.vx; new_vx];
        this_set.SV.vy = [this_set.SV.vy; new_vy];
            
        %{
        % Compute people counting by zone
        this_set = comp_counting(data, this_set, this_idx);
            
        this_set = comp_cos_sim(data, this_set, this_idx, tracks_id, t);
            
        this_set = comp_velocity(data, this_set, this_idx, tracks_id, t);
        %}
    end        
end
    
    

function this_set = comp_counting(data, this_set, this_idx)
% Compute people counting by zone

    % initialize counting state vector
    new_counting = zeros(1,data.TOPO.n_neurons);

    % Get cluster classes
    classes = net_cluster(data.TOPO.output.weight, this_set.raw(this_idx,3:4));

    % For each class, update counting state vector
    for j = 1:length(classes)
        new_counting(classes(j)) = new_counting(classes(j)) + 1;
    end
    
    % Add new counting to state vector
    this_set.SV.counting = [this_set.SV.counting; new_counting];

end

function this_set = comp_cos_sim(data, this_set, this_idx, tracks_id, t)
    
    % Get cluster classes
    classes = net_cluster(data.TOPO.output.weight, this_set.raw(this_idx,3:4));

    dp = zeros(length(tracks_id),2);

    new_cs = zeros(1,data.TOPO.n_neurons);
    new_cs(new_cs(:) == 0) = NaN;
    
    % For each detected track
    for i = 1:length(tracks_id)

        % Get track data
        this_track = this_set.tracks{tracks_id(i)};

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
    this_set.SV.cos_sim = [this_set.SV.cos_sim; new_cs];

end

function this_set = comp_velocity(data, this_set, this_idx, tracks_id, t)
    % vx = dx / dt
    % vy = dy / dt
    
    % Initialize  [vx, vy, class]
    v_tracks = zeros(length(tracks_id),3);
    new_vx = zeros(1,data.TOPO.n_neurons);
    new_vy = zeros(1,data.TOPO.n_neurons);

    % Get cluster classes
    classes = net_cluster(data.TOPO.output.weight, this_set.raw(this_idx,3:4));
    
    % Get active classes
    active_classes = unique(classes);

    % For each detected track
    for i = 1:length(tracks_id)

        % Get track data
        this_track = this_set.tracks{tracks_id(i)};
        
        % Get data row at time 't'
        idt = find(this_track(:,1) == t);

        % Consider only tracks with more than one sample
        if (idt > 1)

            % Calculate track velocity (vx vy)
            v_tracks(i,1:2) = (this_track(idt,2:3) - this_track(idt-1,2:3));

            % Get class
            v_tracks(i,3) = net_cluster(data.TOPO.output.weight, this_track(idt,2:3));

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
    this_set.SV.vx = [this_set.SV.vx; new_vx];
    this_set.SV.vy = [this_set.SV.vy; new_vy];
    
end
