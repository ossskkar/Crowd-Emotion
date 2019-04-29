% DESCRIPTION: Compute the nearest POI to the initial position of track and
%              use it as the POI of origin.

function POI_origin = get_POI_origin(pi, POI, POIDist_treshold)

    % Initialize variable
    POI_origin = 0;

    % Initialize variables
    min_POI_origin_dist = 1000000000;

    % for each POI
    for ai = 1:POI.len

        % Compute the minimum distance between initial point and attractor points
        ai_dist = min(pdist2(pi,POI.groundtruth{ai}.p));

        % Check if attractor ai is the closest to initial point of track ti
        if ((ai_dist < POIDist_treshold) && (ai_dist < min_POI_origin_dist))
            POI_origin = ai;
            min_POI_origin_dist = ai_dist;
        end
    end
end