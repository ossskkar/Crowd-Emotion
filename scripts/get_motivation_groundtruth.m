% Clean up
disp('Cleaning up');
clear; close all; clc;

% Parameters
attractors_file = 'attractors_cstation_cvpr2015';
data_file = 'cstation_cvpr2015';
img_file = 'cstation_cvpr2015.jpg';

% Load data
disp('Loading data');
load(strcat('../data/',attractors_file));
load(strcat('../data/',data_file));

% For each track
for yi = 1:length(data.tracks)

    % Update status
    disp(strcat('Processing track #',num2str(yi)));
    
    % Get current track
    y = data.tracks{yi}(:,2:3);
    
    % Get length of y
    [y_len, ~] = size(y);
    
    % Initialize labels vector
    y_label = zeros(1,y_len);

    % Find points of y crossing attractor ai
    for ai = 1:length(attractors.groundtruth)
        y_label(ismember(round(y),attractors.groundtruth{ai}.p,'rows')) = ai;    
    end

    % For tracks that did not start within an attractor boundary
    if (y_label(1) == 0)
        closest_dist = -1;
        
        % For each attractor
        for ai = 1:length(attractors.groundtruth)
            
            % Find the minimum distance between the last point in y and
            % the points of attractor ai
            att_dist = min(pdist2(y(1,:),attractors.groundtruth{ai}.p));
            
            % If this is the current minimum distance among attractors
            if ((closest_dist == -1) || att_dist < closest_dist)
                
                % Update the minimum distance
                closest_dist = att_dist;
               
                % label the last point of y with attractor ai
                y_label(1) = ai;
            end
        end
    end
    
    % For tracks that did not reach their final destination
    if (y_label(y_len) == 0)
        closest_dist = -1;
        
        % For each attractor
        for ai = 1:length(attractors.groundtruth)
            
            % Find the minimum distance between the last point in y and
            % the points of attractor ai
            att_dist = min(pdist2(y(y_len,:),attractors.groundtruth{ai}.p));
            
            % If this is the current minimum distance among attractors
            if ((closest_dist == -1) || att_dist < closest_dist)
                
                % Update the minimum distance
                closest_dist = att_dist;
               
                % label the last point of y with attractor ai
                y_label(y_len) = ai;
            end
        end
    end
    
    % Assign label points in y
    for yj = y_len-1:-1:1
        if (y_label(yj) == 0)
            y_label(yj) = y_label(yj+1);
        end
    end

    % Update groundtruth labels for track yi
    data.tracks_groundtruth{yi} = y_label;
end



% Save data
disp('Saving data');
save(strcat('../data/',data_file), 'data');
