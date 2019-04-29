% DESCRIPTION: Compute the LOS for each zone at every time instance t

% Clean up
clear; close all; clc;
clc; disp('Step 10.1: Clean up'); 

% Load data
clc; disp('Step 10.2: Load data'); 
load('../data/config');
load(config.dataFile);
load(config.TOPOFile);
load(config.LOSFile);

% Use only training data 
dataset = data.trainSet;

% STEP #1: Compute LOS for each zone at every time t
%{
% Get timeline
t = unique(dataset.raw(:,1));
t_len = length(t);


% Initialize variables
dataset.crowd_state = zeros(t_len, TOPO.n_neurons);
%dataset.crowd_state(:,:) = LOS.max_los;

% For each time t
for ti = 1:t_len
    
    % Update status
    disp(['Step 10.3: Processing data at time ', num2str(ti), '/', num2str(t_len)]); 
    
    % Find active tracks at time ti
    active_tracks = dataset.raw(find(dataset.raw(:,1) == t(ti)),2:4);
    
    % Cluster tracks' positions to zones
    active_tracks(:,4) = net_cluster(TOPO.output.weight, active_tracks(:,2:3));
    active_tracks_len = length(active_tracks(:,1));
    % Find active zones
    active_zones = unique(active_tracks(:,4));
    
    % For each active zone
    for zi = 1:length(active_zones)
        
        % Number of pedestrians in zone zi
        n = length(find(active_tracks(:,4) == active_zones(zi)));
        
        % For each active track
        tracks_v = zeros(active_tracks_len,1);
        for ati = 1:active_tracks_len
            
            % Get row index of track ati corresponding to time ti
            track_row_idx = find(dataset.tracks{active_tracks(ati)}(:,1) == t(ti));
            
            % Get walking speed of track ati at time ti
            tracks_v(ati) = dataset.tracks_v{active_tracks(ati,1)}(track_row_idx);
        end    
        
        % Compute average pedestrian speed (pixels/delta_t) in zone zi
        s = mean(tracks_v);
        
        % Convert s from (pixels/delta_t) to (m/min)
        s = s / 0.5937;
        
        % Compute average area per pedestrian (m^2/p) in zone zi
        a = TOPO.output.area_m(active_zones(zi)) / n;
        
        % Convert a from (pixel^2/ped) to (m^2/ped)
        a = a * 0.018;
        
        % If LOS is within valid range
        if (s/a) < LOS.max_los
            
            % Compute pedestrian flow (p/m-min)
            dataset.crowd_state(ti,active_zones(zi)) = s / a;
        else
            
            % Restrict Maximum LOS
            dataset.crowd_state(ti,active_zones(zi)) = LOS.max_los;
        end
        
    end 
end

% Update data 
data.trainSet = dataset;
%}

% Get crowd states (LOS)
%dataset.crowd_state = data.trainSet.crowd_state;

% STEP #2: Fit data to gaussian models
%{
% Intialize LOS variables
LOS.fit = {};
LOS.rmse = [];
LOS.rof = [];
LOS.f_len = 0;

% Time and interval
time.start = 1;
time.end = length(dataset.crowd_state(:,1));
interval_start = time.start;

% For each zone zi
for zi = 1%:config.TOPO.params.n_neurons
    
    % For each time instance ti
    for ti = 1:time.start:time.end
        
        disp(['Step 10.4: Processing zone ', num2str(zi), ', time ', num2str(ti), '/', num2str(time.end)]); 
        
        % If the time interval is the desired size
        if ((ti - interval_start + 1) == config.LOS_intervalSize)
            
            % Update LOS model counter
            LOS.f_len = LOS.f_len + 1;
            
            % Get range of fit
            LOS.rof = [LOS.rof; [interval_start ti]];
            
            % Get data to be used in fit
            x = (LOS.rof(LOS.f_len,1):LOS.rof(LOS.f_len,2))';
            y = dataset.crowd_state(LOS.rof(LOS.f_len,1):LOS.rof(LOS.f_len,2),zi);
            ys = smoothdata(y);
            
            
            % Try fitting data from 'gauss2' up to 'gauss8'
            hist_rmse = ones(1,8)*1000;
            for gi = 2:8
            
                % Evaluate data to a Gaussian fit
                method.name = ['gauss', num2str(gi)];
                method.error = 0;
                try
                    [LOS.fit{LOS.f_len}, gof] = fit(x,ys, method.name);
                    LOS.rmse(LOS.f_len) = gof.rmse;
                catch
                    method.error = 1;
                end

                % If the method was evaluated without error
                if (~method.error)
                    hist_rmse(gi) = LOS.rmse(LOS.f_len);
                end
            end
            
            % Pick the gaussian with smallest rmse
            [~, gi] = min(hist_rmse);

            %Fit data to gi
            method.name = ['gauss', num2str(gi)];
            %[LOS.fit{LOS.f_len}, gof] = fit(x,ys, method.name);
            [LOS.fit{LOS.f_len}, gof] = fit(x,y, method.name);

            LOS.x{LOS.f_len} = x;
            LOS.x_smooth{LOS.f_len} = linspace(LOS.rof(LOS.f_len,1),LOS.rof(LOS.f_len,2),(LOS.rof(LOS.f_len,2)-LOS.rof(LOS.f_len,1)+1)*10);

            LOS.y{LOS.f_len} = LOS.fit{LOS.f_len}(LOS.x{LOS.f_len});
            LOS.y_smooth{LOS.f_len} = LOS.fit{LOS.f_len}(LOS.x_smooth{LOS.f_len});

            % Compute RMSE
            %LOS.rmse(LOS.f_len) = gof.rmse; % RMSE of smoothed data
            LOS.rmse(LOS.f_len) = sqrt(mean((LOS.y{LOS.f_len} - y).^2)); % RMSE of original data
            
            % Updates start of next interval
            interval_start = ti + 1;
            
            %close all
            %plot(LOS.fit{LOS.f_len}, LOS.x{LOS.f_len}, LOS.y{LOS.f_len}, '*k');
            %[LOS.f_len LOS.rmse(LOS.f_len)]
            %pause();
        end
    end
end
%}



% Save data
clc; disp('Step 10.6: Save data');
save(config.dataFile, 'data');
save(config.LOSFile, 'LOS');

% Clean on exit
%clear; close all; clc;
clc; disp('Step 10: Done!');


