% DESCRIPTION
% Creates time scale, cluster the time scale to a desired size
%
% Parameters:
%    states => Sequence of state vectors
%    max_scale => The desired maximum number in the time scale
%
% Return:
%    time_scale => Time scale to be used for time transition of states in
%    HMM model

function time_scale = create_time_scale(states, max_scale)

    % Initialize variables
    time_scale = [];
    trans_time = [];
    count = 0;
    
    % Check for short sequence
    if (length(states)<2)
        time_scale = 1;
        return;
    end

    % Get transition times
    for i = 2:length(states)
        
        % Update transition time counter
        count = count + 1;
        
        % If a transition occurs
        if (states(i) ~= states(i-1))
            trans_time = [trans_time count];
            count = 0;
        end
    end

    % Sort and clean duplicates of transition times
    time_scale = sort(unique(trans_time));
    
    % Add lower segment to scale in exponential fashion
    min_time = min(trans_time);
    while (min_time > 1)
        min_time = floor(sqrt(min_time));
        time_scale = [ min_time time_scale];
    end
    
    % Add upper segment to scale in mean incremental fashion
    max_time = max(time_scale);
    while (length(time_scale) < max_scale)
        i = length(time_scale);
        max_time = ceil(time_scale(i) + mean(time_scale));
        time_scale = [time_scale max_time];
    end
    
end