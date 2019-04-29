% DESCRIPTION: Estimate the attractor (motivation) of tracks in a dataset
%              by computing innovation with respect to behavior model of
%              each attractor and selecting the one with smaller innovation

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

% Get all the attractors points (needed later)
att_all_p = [];
att_len = length(attractors.groundtruth);

for ai = 1:att_len
    att_all_p = [att_all_p; attractors.groundtruth{ai}.p];
end

% Sliding window size
data.sw_size = 5; % Assign high number to disable sliding window

% Distance threshold for adaptive sliding window 
data.dist_threshold = 800000000; % Assign high number to disable sliding window

% Time interval size
data.delta_t = 0.64;

% Number of tracks 
num_tracks = length(data.tracks);

ti_init = 1;
ti_final = num_tracks;

% For each track ti
for ti = ti_init:ti_final

    % Update status
    disp(strcat('Processing track #',num2str(ti)));
    
    % Get current track
    ti_data = data.tracks{ti}(:,2:3);
    [ti_len, ~] = size(ti_data);
    t0 = 1;

    % Initialize vector for motivation estimation
    m = zeros(1,ti_len);

    % Start clock
    tic;

    % Initialize vector to acumulate innovation for each attractor
    att_innovation = zeros(att_len,1);
    
    % Generate prototype tracks for new starting point y0
    %proto_tracks = get_proto_tracks(ti_data(t0,:),attractors.groundtruth);

    % Flag variable to indicate whether the previous point is in an attractor
    in_attractor(2) = ismember(round(ti_data(t0,:)),att_all_p,'rows');

    % For each point of y after observing half of the track
    %for pj = round(ti_len/2)+1:ti_len

    % For each point of y
    for pj = 2:ti_len
        
        % Update status
        %disp(strcat('Processing track #',num2str(ti),'-p#',num2str(pj)));
        
        % Check if current point is in an attractor
        in_attractor(1) = in_attractor(2);
        in_attractor(2) = ismember(round(ti_data(pj,:)),att_all_p,'rows');

        % Changing from been in an attractor to not been, signals a change
        % of segment
        if (in_attractor(1) == 1 && in_attractor(2) == 0)

            % Update initial segment point
            t0 = pj;

            % Initialize vector to acumulate innovation for each attractor
            att_innovation = zeros(att_len,1);
            
        % If the number of observations is bigger than sliding window or 
        % surpass the distance threshold    
        elseif (((pj - t0) > data.sw_size) || (data.tracks_tot_dist(ti) > data.dist_threshold))
       
            % Update initial segment point
            t0 = pj;

            % Initialize vector to acumulate innovation for each attractor
            att_innovation = zeros(att_len,1);
        end

        % Get motivation of track y(1:pj,:)
        %[data.tracks_tot_dist(ti), m(pj)] = get_attractor_dest(ti_data(t0:pj,:), attractors.groundtruth, proto_tracks);
       
        % For each attractor
        for ai = 1:att_len
            
            % Compute velocity 
            pi_v = sqrt((ti_data(pj,1) - ti_data(pj-1,1))^2 + (ti_data(pj,2) - ti_data(pj-1,2))^2)/data.delta_t;
            
            % Compute the expected point
            p_exp = ti_data(pj-1,:);
            cp = [round(ti_data(pj-1,2)), round(ti_data(pj-1,1))];
            if (cp(1) == 0) cp(1) = 1; end
            if (cp(2) == 0) cp(2) = 1; end
            
            p_exp(1) = p_exp(1) + pi_v * attractors.groundtruth{ai}.df_x(cp(1), cp(2));
            p_exp(2) = p_exp(2) + pi_v * attractors.groundtruth{ai}.df_y(cp(1), cp(2));
            
            % Compute innovation
            att_innovation(ai,1) = att_innovation(ai,1) + ...
                sqrt((ti_data(pj,1) - p_exp(1))^2 + (ti_data(pj,2) - p_exp(2))^2);
        end
        
        % The predicted motivation corresponds to the attractor with
        % smalles innovation
        [~, m(pj)] = min(att_innovation);
        
    end

    % Check time elapsed
    t = toc;

    % Save the record of predicted motivations
    data.tracks_prediction{ti} = m;
    
    % Compute prediction accuracy for track ti
    %data.tracks_eval(ti) = length(find(data.tracks_groundtruth{ti} == m))/length(data.tracks{ti});
    
    % Compute prediction accuracy for track ti after observing half track
    data.tracks_eval(ti) = length(find(data.tracks_groundtruth{ti}(round(ti_len/2):ti_len) == m(round(ti_len/2):ti_len)))/(round(ti_len/2));
    if (data.tracks_eval(ti) > 1) data.tracks_eval(ti) = 1; end
    
    % Update status
    disp(strcat('Track-',num2str(ti),'-point-',num2str(pj),'- processed in: ',num2str(t),'secs'));

end

% Show mean accuracy
%clc;
disp(strcat('Number of tracks: ',num2str(ti),' - Accuracy: ', num2str(mean(data.tracks_eval))));
disp(strcat('Number of tracks: ',num2str(ti),' - Accuracy: ', num2str(data.tracks_eval(ti))));

%Save data
%save(strcat('../data/',data_file,'_eval_inn_half_sw30'), 'data');



% PLOT FOR DEBUGGIN PURPOSES
%{
% Get gt groundtruth
gt = attractors.groundtruth;

%y0 = 1;
% Generate prototype tracks for new starting point y0
proto_tracks = get_proto_tracks(ti_data(1,:),attractors.groundtruth);

% Open figure in fullscreen mode
figure;
pause(0.00001);
frame_h = get(handle(gcf),'JavaFrame');
set(frame_h,'Maximized',1);

% Plot background image to specific coordinates
img = imread(strcat('../images/',img_file));
imagesc([0 data.inf.frame_size(1)], [0 data.inf.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% For each attractor 
for a_idx = 1:length(gt)

    % Plot attractor points
    plot(gt{a_idx}.p(:,1), gt{a_idx}.p(:,2),'.r');
    
    % Plot attractor boundary
    %plot(gt{a_idx}.p(gt{a_idx}.b,1), gt{a_idx}.p(gt{a_idx}.b,2),'b');
    
    % Plot number of attractor
    text(mean(gt{a_idx}.p(:,1)),mean(gt{a_idx}.p(:,2)),num2str(a_idx),'FontSize',20);
    
    % Plot proto track
    plot(proto_tracks{a_idx}(:,1), proto_tracks{a_idx}(:,2),'*r');
    
end

% Plot track y
plot(data.tracks{ti}(:,2), data.tracks{ti}(:,3), '*g');

% Plot initial point 
scatter(data.tracks{ti}(1,2), data.tracks{ti}(1,3), 100,...
    'filled', 'MarkerEdgeColor', [0 0 0],...
    'MarkerFaceColor', [0 1 0]);

% Plot final point 
scatter(data.tracks{ti}(length(ti_data),2), data.tracks{ti}(length(ti_data),3), 100,...
    'filled', 'MarkerEdgeColor', [0 0 0],...
    'MarkerFaceColor', [1 0 0]);

hold off

% Hide Axis values
ax = gca;
%ax.Visible = 'off';

% Reduce white space when ploting a figure
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
%}



