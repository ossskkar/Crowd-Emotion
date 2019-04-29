% DESCRIPTION: Estimate the attractor (motivation) of tracks in a dataset
%              by computing the prototype tracks to each attractor and 
%              selecting the one with the minimum distance difference.

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
for ai = 1:length(attractors.groundtruth)
    att_all_p = [att_all_p; attractors.groundtruth{ai}.p];
end

% Sliding window size
data.sw_size = 300000000000000000; % Assign high number to disable sliding window

% Distance threshold for adaptive sliding window 
data.dist_threshold = 800000000; % Assign high number to disable sliding window

% For each track yi
for yi = 1%:length(data.tracks)

    % Update status
    disp(strcat('Processing track #',num2str(yi)));
    
    % Get current track
    y = data.tracks{yi}(:,2:3);
    [y_len, ~] = size(y);
    y0 = 1;

    % Initialize vector for motivation estimation
    m = zeros(1,y_len);

    % Start clock
    tic;

    % Generate prototype tracks for new starting point y0
    proto_tracks = get_proto_tracks(y(y0,:),attractors.groundtruth);

    % Flag variable to indicate whether the previous point is in an attractor
    in_attractor(2) = ismember(round(y(y0,:)),att_all_p,'rows');

    % For each point of y after observing half of the track
    for pj = round(y_len/2)+1:y_len

    % For each point of y
    %for pj = 2:length(y)
        
        % Update status
        %disp(strcat('Processing track #',num2str(yi),'-p#',num2str(pj)));

        % Check if current point is in an attractor
        in_attractor(1) = in_attractor(2);
        in_attractor(2) = ismember(round(y(pj,:)),att_all_p,'rows');

        % Changing from been in an attractor to not been, signals a change
        % of segment
        if (in_attractor(1) == 1 && in_attractor(2) == 0)

            % Update initial segment point
            y0 = pj;

            % Generate prototype tracks for new starting point y0
            proto_tracks = get_proto_tracks(y(y0,:),attractors.groundtruth);
            
        % If the number of observations is bigger than sliding window or 
        % surpass the distance threshold    
        elseif (((pj - y0) > data.sw_size) || (data.tracks_tot_dist(yi) > data.dist_threshold))
       
            % Update initial segment point
            y0 = pj;

            % Generate prototype tracks for new starting point y0
            proto_tracks = get_proto_tracks(y(y0,:),attractors.groundtruth);
        end

        % Get motivation of track y(1:pj,:)
        [data.tracks_tot_dist(yi), m(pj)] = get_attractor_dest(y(y0:pj,:), attractors.groundtruth, proto_tracks);
    end

    % Check time elapsed
    t = toc;

    % Save the record of predicted motivations
    data.tracks_prediction{yi} = m;
    
    % Compute prediction accuracy for track yi
    %data.tracks_eval(yi) = length(find(data.tracks_groundtruth{yi} == m))/length(data.tracks{yi});
    
    % Compute prediction accuracy for track yi after observing half track
    data.tracks_eval(yi) = length(find(data.tracks_groundtruth{yi}(round(y_len/2):y_len) == m(round(y_len/2):y_len)))/(round(y_len/2));
    
    % Update status
    disp(strcat('Track-',num2str(yi),'-point-',num2str(pj),'- processed in: ',num2str(t),'secs'));

end

% Show mean accuracy
%clc;
%disp(strcat('Number of tracks: ',num2str(yi),' - Accuracy: ', num2str(mean(data.tracks_eval))));
disp(strcat('Number of tracks: ',num2str(yi),' - Accuracy: ', num2str(data.tracks_eval(yi))));

%Save data
save(strcat('../data/',data_file,'_eval_all_no_sw'), 'data');

% Plot for debugging purposes
%{
% Get gt groundtruth
gt = attractors.groundtruth;

%y0 = 1;
% Generate prototype tracks for new starting point y0
proto_tracks = get_proto_tracks(y(1,:),attractors.groundtruth);

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
plot(data.tracks{yi}(:,2), data.tracks{yi}(:,3), '*g');

% Plot initial point 
scatter(data.tracks{yi}(1,2), data.tracks{yi}(1,3), 100,...
    'filled', 'MarkerEdgeColor', [0 0 0],...
    'MarkerFaceColor', [0 1 0]);

% Plot final point 
scatter(data.tracks{yi}(length(y),2), data.tracks{yi}(length(y),3), 100,...
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



