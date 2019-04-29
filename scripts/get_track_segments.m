% DESCRIPTION: A track 'y' can pass through one or many attractors', this
%              function finds the segments of track y for each attractor 
%              influencing it.
%
% INPUT:       y => a tracjectory
%              attractors => struct list of attractors
%
% OUTPUT:      segments => list of points where the segment starts at
%              segment(n) and ends at segment(n+1)

function segments = get_track_segments(y,attractors)

    % Initialize variables 
    [y_len, ~] = size(y);
    y_labels = zeros(y_len,1);

    % For each point of track y 
    for yi = 1:y_len

        % For each attractor
        for ai = 1:length(attractors)
            
            % Mark point yi if it is in attractor ai
            if ismember(round(y(yi,:)),attractors{ai}.p,'rows')
                y_labels(yi) = 1;
            end
        end
    end

    % Assign segments
    segments = [1; find(diff(y_labels)==1)+1];
    %segments = [0; y_len - find(diff(flipud(y_labels))==1)];
    
    % Add final segment for short paths
    if (segments(length(segments))< y_len)
        segments = [segments; y_len];
    end
    
    % Sort segments' entries
    segments = sort(segments);
end