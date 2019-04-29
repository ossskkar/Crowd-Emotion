% DESCRIPTION: Estimate the attractor (motivation) of track y by computing
%              the prototype tracks to each attractor and selecting the one
%              with the minimum distance difference.
%
% INPUT:       y => trajectory in R^2
%              attractors => cell list of attractors
%
% OUTPUT:      m => the index number of the estimated attractor 

%function [m, new_y] = get_motivation(y, attractors, proto_tracks)
function [tot_dist, m] = get_attractor_dest(y, attractors, proto_tracks)

    % Get number of attractors
    a_len = length(attractors);

    % Initialize proto tracks distance
    pt_dist = zeros(a_len,1);

    % Get last point of y
    [y_len, ~] = size(y);
    
    % For each attractor
    for ai = 1:a_len
        
        % Find the closest point of this proto track to the last point of y
        [~, yf] = min(pdist2(y(y_len,:),proto_tracks{ai}));
        
        % Compute distance for each point of y to the closest point in
        % proto track
        ai_dist = pdist2(proto_tracks{ai}(1:yf,:),y);
        
        % If the proto track is only 1-sample long
        if ismember(1,size(proto_tracks{ai}(1:yf,:)))
            
            % Sum the distance to each point of y
            pt_dist(ai) = sum(ai_dist);
            
            % Get the max distance 
        else 
            % Sum the min distance to each point of y
            pt_dist(ai) = sum(min(ai_dist));
        end
    end
    
    % Get attractor with minimum distance
    [tot_dist, m] = min(pt_dist);
end