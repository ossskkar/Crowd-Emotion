% DESCRIPTION: Compute the LOS for each zone at every time instance t

% Clean up
clear; close all; clc;
clc; disp('Step 10.1: Clean up'); 

% Load data
clc; disp('Step 10.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% For training/test sets
for trainTest = 1:2

    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};
        else
            dataset = data.testSet{set_i};
        end

        % STEP #1: Compute LOS for each zone at every time t
        
        % Get timeline
        t = unique(dataset.raw(:,1));
        t_len = length(t);

        % Initialize variables
        dataset.crowd_state = zeros(t_len, data.TOPO.n_neurons);
        %dataset.crowd_state(:,:) = LOS.max_LOS;

        % For each time t
        for ti = 1:t_len

            % Update status
            disp(['Step 10.3: Processing data at time ', num2str(ti), '/', num2str(t_len)]); 

            % Find active tracks at time ti
            active_tracks = dataset.raw(find(dataset.raw(:,1) == t(ti)),2:4);

            % Cluster tracks' positions to zones
            active_tracks(:,4) = net_cluster(data.TOPO.output.weight, active_tracks(:,2:3));
            active_tracks_len = length(active_tracks(:,1));
            
            % Find active zones
            active_zones = unique(active_tracks(:,4));

            % For each active zone
            for zi = 1:length(active_zones)

                % Index and number of pedestrians active in zone zi
                active_tracks_zi = find(active_tracks(:,4) == active_zones(zi));
                active_tracks_zi_len = length(active_tracks_zi);
                
                % For each active track
                tracks_v = zeros(active_tracks_zi_len,1);
                for ati = 1:active_tracks_zi_len

                    % Process only tracks existing in the dataset
                    if (active_tracks(active_tracks_zi(ati)) <= dataset.tracks_len)
                        
                        % Get row index of track ati corresponding to time ti
                        track_row_idx = find(dataset.tracks{active_tracks(active_tracks_zi(ati),1)}(:,1) == t(ti));

                        if (~isempty(track_row_idx))
                            % Get walking speed of track ati at time ti
                            tracks_v(ati) = dataset.tracks_v{active_tracks(active_tracks_zi(ati),1)}(track_row_idx);
                        end
                    end
                end    

                % Compute average pedestrian speed (pixels/delta_t) in zone zi
                s = mean(tracks_v);

                % Convert s from (pixels/delta_t) to (m/min)
                s = s / config.convert.speed_factor; 

                % Compute average area per pedestrian (m^2/p) in zone zi
                a = data.TOPO.output.area_m(active_zones(zi)) / active_tracks_zi_len;

                % Convert a from (pixel^2/ped) to (m^2/ped)
                a = a * config.convert.area_factor;

                % If LOS is within valid range
                if (s/a) < data.LOS.max_LOS

                    % Compute pedestrian flow (p/m-min)
                    dataset.crowd_state(ti,active_zones(zi)) = s / a;
                else

                    % Restrict Maximum LOS
                    dataset.crowd_state(ti,active_zones(zi)) = data.LOS.max_LOS;
                end
            end 
        end
        
        % STEP #2: Fit data to gaussian process regression models
        
        % Apply this step only to train sets
        if (trainTest == 1)
            
            % Intialize LOS variables
            %dataset.LOS.gprMdl = {};
            dataset.LOS.ypred = {};
            %dataset.LOS.rof = zeros(config.TOPO.params.n_neurons, 2);

            % For each zone zi
            for zi = 1:config.TOPO.params.n_neurons

                % Update status
                disp(['Step 10.4: Processing zone ', num2str(zi)]); 

                % Get data
                y = smooth(dataset.crowd_state(:,zi));
                x = (1:length(y))';

                % Train gaussian xprocess model
                gprMdl = fitrgp(x,y,'Basis','linear',...
                      'FitMethod','exact','PredictMethod','exact');

                % Store model prediction
                dataset.LOS.ypred{zi} = resubPredict(gprMdl);

                % Store model's range of fit
                %dataset1.LOS.rof(zi,:) = [x(1) x(length(x))];
            end
        end
        
      % Update a dataset
        if (trainTest == 1)
            data.trainSet{set_i} = dataset;
        else
            data.testSet{set_i} = dataset;
        end
    end
end

% Save data
clc; disp('Step 10.6: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 10: Done!');


