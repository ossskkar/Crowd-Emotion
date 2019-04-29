% DESCRIPTION: Compute the expected DTM given the mean walking speed and
%              the DTM corresponding to the POI pair

function dtm_expected = get_DTM_expected(DTM, track_mean_v, delta_t)

    % Initialize expected DTM
    dtm_expected = {};
    
    % Compute the expected time for track (distance / mean velocity)
    track_exp_t = DTM.mean_dist(1) / track_mean_v;

    % If a DTM is provided
    if (~isempty(DTM.mean_time))
        
        % Get distance data
        dtm_temp.dist = DTM.mean_dist;
        dtm_temp.len = DTM.len;
        
        % Adjust time to expectation of track ti (converted temporarily 
        % to integers for convenience)
        dtm_temp.time = int32(DTM.mean_time .* (track_exp_t/DTM.mean_time(DTM.len)) .*100);
        
        % Compute expected length of DTM
        dtm_expected.len = ceil(track_exp_t / delta_t);
        
        % For each time instant t
        for di = 1:dtm_expected.len
            
            % Use time temporarily as integer 
            dtm_expected.time(di) = int32((di-1) * delta_t * 100);
            
            % Find the sample at time t
            if (di == dtm_expected.len) % if di is the last sample
                di_idx = dtm_temp.len; % use the last sample of DTM
            else % else, find the closest sample
                di_idx = find(dtm_temp.time == dtm_expected.time(di));
            end
            
            % If there is a sample at the desired time
            if (~isempty(di_idx))
                
                % Use data at time t
                dtm_expected.dist(di) = dtm_temp.dist(di_idx(1));
                
            % If no sample at the exact same time
            else
                
                % Get idx of the closest sample index
                [~, di_idx] = min(abs(dtm_temp.time - dtm_expected.time(di)));
                
                % If the time of the sample found is greater than the desired sample
                if (dtm_temp.time(di_idx) > dtm_expected.time(di))
                    
                    final_idx = di_idx;
                    
                    % If this is not the first sample
                    if (di_idx > 1)
                        init_idx = di_idx-1;
                    else
                        init_idx = final_idx;
                    end
                else
                    init_idx = di_idx;
                    
                    % If this is not the last sample
                    if (di_idx < dtm_temp.len)
                        final_idx = di_idx+1;
                    else
                        final_idx = init_idx;
                    end
                end  
                
                % Compute the proportional value of the distance for sample di
                if (init_idx == final_idx)
                    dtm_expected.dist(di) = dtm_temp.dist(init_idx);
                else
                    dtm_expected.dist(di) = dtm_temp.dist(init_idx) + ...
                        (dtm_temp.dist(final_idx) - dtm_temp.dist(init_idx)) * ...
                        (double(dtm_expected.time(di) - dtm_temp.time(init_idx))/double(dtm_temp.time(final_idx) - dtm_temp.time(init_idx))); 
                end
            end
        end
        
        % Convert time back to decimal
        dtm_expected.time = double(dtm_expected.time)./100;
    end
end