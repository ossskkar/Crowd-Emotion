% DESCRITPION: Using data from a simulation, compute the attractors 
%              groundtruth: points, boundaries and direction field.

% Clean up
clear; close all; clc;
clc; disp('Step 2.4.1: Clean up');

% Load data
clc; disp('Step 2.4.2: Load data');
load('../data/config');
load(config.POIFile_raw);

% Initialize attractors groundtruth
gt = cell(data.intent_count+data.temp_intent_count,1);

% Correct axis
cidx = zeros(data.intent_count+data.temp_intent_count,1);
cidx(1) = 1;
cidx(2) = 2;
cidx(3) = 3;
cidx(4) = 4;
cidx(5) = 5;
cidx(6) = 6;
cidx(7) = 7;
cidx(8) = 8;
cidx(9) = 9;
cidx(10) = 10;
cidx(11) = 11;
cidx(12) = 12;
cidx(13) = 13;
cidx(14) = 14;
cidx(15) = 15;
cidx(16) = 16;
cidx(17) = 17;
cidx(18) = 18;
cidx(19) = 19;
cidx(20) = 20;
cidx(21) = 21;
cidx(22) = 22;

% For each POI 
for a_idx = 1:data.intent_count

    clc; disp(strcat('Step 2.4.3: Processing POI #',num2str(a_idx)));
    
    % Get index of POI points
    p_idx = find(data.floor.intent.ti == cidx(a_idx));
    
    % Get attractor points
    gt{a_idx}.p = [data.floor.intent.x(p_idx), config.frame_size(2)+1 - data.floor.intent.y(p_idx)];
    
    % Get attractor boundaries
    gt{a_idx}.b = boundary(gt{a_idx}.p(:,1), gt{a_idx}.p(:,2), 0.1);
    
    % Initialize direction field
    boundary_data = zeros(config.frame_size(2), config.frame_size(1));
    
    % Mark points of attractor
    boundary_data(gt{a_idx}.p(:,2), gt{a_idx}.p(:,1)) = -1;
    boundary_data = flipud(boundary_data);
    
    % Mark wall pixels
    boundary_data(fliplr(data.floor.img_wall)) = 1;
    
    % Calculate distance to temporal intent ti
    intent_dist = fastSweeping(boundary_data);
    
    % Compute direction field
    [gt{a_idx}.df_y, gt{a_idx}.df_x] = getNormalizedGradient(boundary_data, -intent_dist);
    gt{a_idx}.df_y = -flipud(gt{a_idx}.df_y); % Correct axis orientation
    gt{a_idx}.df_x = flipud(gt{a_idx}.df_x);
    
end

% Number of attractors so far
a_num = data.intent_count;

% For each temporal attractor
for a_idx = 1:data.temp_intent_count
    
    clc; disp(strcat('Step 2.4.4: Processing POI #',num2str(a_num + a_idx)));
    
    % Get index of POI points
    p_idx = find(data.floor.intent.ti_t == a_idx);
    
    % Get POI points
    gt{a_num + a_idx}.p = [data.floor.intent.x_t(p_idx), config.frame_size(2) - data.floor.intent.y_t(p_idx)];
    
    % Get POI boundaries
    gt{a_num + a_idx}.b = boundary(gt{a_num + a_idx}.p(:,1), gt{a_num + a_idx}.p(:,2), 0.1);
    
    % Initialize direction field
    boundary_data = zeros(config.frame_size(2), config.frame_size(1));
    
    % Mark points of attractor
    boundary_data(gt{a_num + a_idx}.p(:,2), gt{a_num + a_idx}.p(:,1)) = -1;
    boundary_data = flipud(boundary_data);
    
    % Mark wall pixels
    boundary_data(fliplr(data.floor.img_wall)) = 1;
    
    % Calculate distance to temporal POI ti
    intent_dist = fastSweeping(boundary_data);
    
    % Compute direction field
    [gt{a_num + a_idx}.df_y, gt{a_num + a_idx}.df_x] = getNormalizedGradient(boundary_data, -intent_dist);
    gt{a_num + a_idx}.df_y = - flipud(gt{a_num + a_idx}.df_y); % Correct axis orientation
    gt{a_num + a_idx}.df_x = flipud(gt{a_num + a_idx}.df_x);
    
end

% Update POI structure
POI.groundtruth = gt;
POI.len = length(gt);

% Generate pairs of all possible combination of POIs
% NOTE: pair [a b] ~= pair [b a]
clc; disp('Step 2.4.5: Generate POI pairs');
POI.pairs = nchoosek(1:POI.len,2);
POI.pairs = [POI.pairs; [POI.pairs(:,2), POI.pairs(:,1)]];

% Get number of POI pairs
[POI.pairs_len, ~] = size(POI.pairs);

% Convert POI data from pixel to meters
%{
clc; disp('Step 2.4.6: Convert POI data from pixel to meters');
for ai = 1:POI.len
    
    % Convert attractor's sample points
    [POI.groundtruth{ai}.p_in_m(:,1), POI.groundtruth{ai}.p_in_m(:,2)] = ...
        tformfwd(config.convert.tform_p2m, POI.groundtruth{ai}.p(:,1), POI.groundtruth{ai}.p(:,2));
    POI.groundtruth{ai}.p_in_m(:,1) = round(POI.groundtruth{ai}.p_in_m(:,1),2);
    POI.groundtruth{ai}.p_in_m(:,2) = round(POI.groundtruth{ai}.p_in_m(:,2),2);
end
%}

% Save data
clc; disp('Step 2.4.7: Save data');
clear data;
load(config.dataFile);
data.POI = POI;
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 2: Done!');
