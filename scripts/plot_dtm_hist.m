
% Clean up
clear; close all; clc;
clc; disp('Clean up'); 

% Load data
clc; disp('Load data'); 
load('../data/config');
load(config.dataFile);

% Select POI pair
pai = 1;

% Select dataset
set_i = 1;
dataset = data.trainSet{set_i};

% Get indexes of tracks in this POI pair
pa_tracks_idx = find(dataset.tracks_POI_pair(:,3) == pai);
pa_tracks_len = length(pa_tracks_idx);

max_time = length(dataset.DTM{pai}.track_dist(1,:));
max_dist = max(max(dataset.DTM{pai}.track_dist));

% FIGURE 1: Tracks of cluster pai

% Plot background image to specific coordinates
figure;
img = imread(config.imgFile);
imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% Plot tracks of this POI pair
for ti = 1:pa_tracks_len
    plot(dataset.tracks{pa_tracks_idx(ti)}(:,2), dataset.tracks{pa_tracks_idx(ti)}(:,3));
end

% For each POI 
for pi = 1:data.POI.len

    % Plot attractor boundary
    plot(data.POI.groundtruth{pi}.p(data.POI.groundtruth{pi}.b,1), data.POI.groundtruth{pi}.p(data.POI.groundtruth{pi}.b,2),'b');
    
    if (pi == data.POI.pairs(pai,1))
        a_color = 'b'; % Origin POI
    elseif (pi == data.POI.pairs(pai,2))
        a_color = 'g'; % Destination POI
    else
        a_color = 'y'; % Any other POI
    end
    
    h= fill(data.POI.groundtruth{pi}.p(data.POI.groundtruth{pi}.b,1), data.POI.groundtruth{pi}.p(data.POI.groundtruth{pi}.b,2),a_color);
    set(h,'facealpha',0.6);
        
    % Plot number of attractor
    text(mean(data.POI.groundtruth{pi}.p(:,1)),mean(data.POI.groundtruth{pi}.p(:,2)),num2str(pi),'FontSize',20);
end

hold off

% Hide Axis values
ax = gca;
ax.Visible = 'off';
pbaspect([2 1 1]);


% FIGURE #2: Distance-to-Motivation time series (unnormalized)

figure;
hold on

% Plot tracks in pai
for ti = 1:pa_tracks_len
   [ti_len, ~] = size(dataset.tracks{pa_tracks_idx(ti)});
   plot(dataset.DTM{pai}.track_dist(ti,1:ti_len));
end

hold off
xlabel('Time');
ylabel('Distance to Motivation');
pbaspect([2 1 1]);
axis ([1 max_time 0 max_dist]);


% FIGURE #3: Distance-to-Motivation time series (normalized)

figure;
hold on

% Plot tracks in pai
for ti = 1:pa_tracks_len
   [ti_len, ~] = size(dataset.tracks{pa_tracks_idx(ti)});
   plot(dataset.DTM{pai}.track_dist_normalized(ti,:));
end

% Plot mean DTM for pai
plot(dataset.DTM{pai}.mean_dist,'k','LineWidth',6);
plot(dataset.DTM{pai}.mean_dist,'y','LineWidth',3);

plot(dataset.DTM{pai}.mean_dist-config.DTM{set_i}.tolerance*dataset.DTM{pai}.std,'k','LineWidth',6);
plot(dataset.DTM{pai}.mean_dist-config.DTM{set_i}.tolerance*dataset.DTM{pai}.std,'g','LineWidth',3);

plot(dataset.DTM{pai}.mean_dist+config.DTM{set_i}.tolerance*dataset.DTM{pai}.std,'k','LineWidth',6);
plot(dataset.DTM{pai}.mean_dist+config.DTM{set_i}.tolerance*dataset.DTM{pai}.std,'r','LineWidth',3);

hold off
xlabel('Time');
ylabel('Distance to Motivation');
pbaspect([2 1 1]);
axis ([1 max_time 0 max_dist]);

% FIGURE #4: Emotional state for DTM
%{
figure;
hold on

% Compute emotion gradient 
gradient = get_emotion_gradient(emotion, emotion.dist_hist{pai}, [hist_len, max_dist]);

% Plot background gradient
image(gradient);

% Plot mean histogram of pai
plot(emotion.dist_hist{pai}(1:hist_len),'k','LineWidth',6);
plot(emotion.dist_hist{pai}(1:hist_len),'y','LineWidth',3);

hold off
axis ([1 hist_len 0 max_dist]);
xlabel('Time');
ylabel('Distance to Motivation');
pbaspect([2 1 1]);


% FIGURE #6: Plot a specific path in the environment
% Plot background image to specific coordinates
figure;
img = imread(strcat('../images/',img_file));
imagesc([0 data.inf.frame_size(1)], [0 data.inf.frame_size(2)], img);
set(gca,'YDir','normal')
hold on

% For each attractor 
for pi = 1:attractor_len

    % Plot attractor boundary
    plot(attractors.groundtruth{pi}.p(attractors.groundtruth{pi}.b,1), attractors.groundtruth{pi}.p(attractors.groundtruth{pi}.b,2),'b');
    
    if (pi == emotion.paths_origin_dest(pai,1))
        a_color = 'b';
    elseif (pi == emotion.paths_origin_dest(pai,2))
        a_color = 'g';
    else
        a_color = 'y';
    end
    
    h= fill(attractors.groundtruth{pi}.p(attractors.groundtruth{pi}.b,1), attractors.groundtruth{pi}.p(attractors.groundtruth{pi}.b,2),a_color);
    set(h,'facealpha',0.6);
        
    % Plot number of attractor
    text(mean(attractors.groundtruth{pi}.p(:,1)),mean(attractors.groundtruth{pi}.p(:,2)),num2str(pi),'FontSize',20);
end

% Plot a specific path
ti = 1;
plot(data.tracks{pa_tracks_idx(ti)}(:,2), data.tracks{pa_tracks_idx(ti)}(:,3), 'LineWidth',2);

hold off

% Hide Axis values
ax = gca;
ax.Visible = 'off';
pbaspect([2 1 1]);

% Reduce white space 
ax = gca;
outerpos = ax.OuterPosition;
tti = ax.TightInset; 
left = outerpos(1) + tti(1);
bottom = outerpos(2) + tti(2);
ax_width = outerpos(3) - tti(1) - tti(3);
ax_height = outerpos(4) - tti(2) - tti(4);
ax.Position = [left bottom ax_width ax_height];


% FIGURE #7: Plot DTM histogram for a specific path

% Get data of track ti
ti = 1;
ti_track(:,2:3) = data.tracks{pa_tracks_idx(ti)}(:,2:3);
[ti_len, ~] = size(ti_track);
ti_track(:,1) = (0:0.64:0.64*(ti_len-1)); 

% Get adjusted dtm histogram
dtm_hist = get_dtm_hist_adjusted(ti_track, delta_t, emotion.track_data{pai}(ti,1), emotion, pai);

% Compute emotion gradient 
max_dist = round(max([emotion.track_data{pai}(ti,1:ti_len) dtm_hist.dist]));
gradient = get_emotion_gradient(emotion, dtm_hist.dist, [dtm_hist.len, max_dist]);

% Histogram of expected and actual DTM
figure;
hold on

% Plot background gradient
x = [1 max(dtm_hist.time)]; y = [0 max_dist];
image(x, y, gradient);

stem(dtm_hist.time, dtm_hist.dist, '-y');
stem(ti_track(:,1), emotion.track_data{pai}(ti,1:ti_len),'-b');

plot(dtm_hist.time, dtm_hist.dist, 'k', 'LineWidth', 6);
plot(dtm_hist.time, dtm_hist.dist, 'y', 'LineWidth', 3);

plot(ti_track(:,1), emotion.track_data{pai}(ti,1:ti_len), 'w', 'LineWidth', 6);
plot(ti_track(:,1), emotion.track_data{pai}(ti,1:ti_len), 'b', 'LineWidth', 3);

hold off

axis ([1 max(dtm_hist.time) 0 max_dist]);
%legend('','','Expected DTM', 'Actual DTM');
xlabel('Time');
ylabel('Distance to Motivation');
pbaspect([2 1 1]);

% Reduce white space 
ax = gca;
outerpos = ax.OuterPosition;
tti = ax.TightInset; 
left = outerpos(1) + tti(1);
bottom = outerpos(2) + tti(2);
ax_width = outerpos(3) - tti(1) - tti(3);
ax_height = outerpos(4) - tti(2) - tti(4);
ax.Position = [left bottom ax_width ax_height];


% FIGURE #8: Plot Emotional state histogram for a specific path


%for ti = 1:pa_tracks_len
%    ti

% Get data of track ti
%ti = 280;
ti_track = [];
ti_track(:,2:3) = data.tracks{pa_tracks_idx(ti)}(:,2:3);
[ti_len, ~] = size(ti_track);
ti_track(:,1) = (0:0.64:0.64*(ti_len-1)); 


figure;
hold on

stem(ti_track(:,1), emotion.emotion_cumulative{pa_tracks_idx(ti)}, '-ok', 'BaseValue', 0.5);
%stem(emotion.emotion_cumulative{pa_tracks_idx(ti)},'-r');

axis ([0 max(ti_track(:,1))+1 0.40 0.60]);
pbaspect([2 1 1]);
xlabel('Time');
ylabel('Emotional Valence');

% Reduce white space 
ax = gca;
outerpos = ax.OuterPosition;
tti = ax.TightInset; 
left = outerpos(1) + tti(1);
bottom = outerpos(2) + tti(2);
ax_width = outerpos(3) - tti(1) - tti(3);
ax_height = outerpos(4) - tti(2) - tti(4);
ax.Position = [left bottom ax_width ax_height];

%pause();
%close all
%end
%}



% Area Under the Curve of expected and actual DTM
%{
subplot(3,1,2);
hold on
plot(ti_track(:,1), ti_auc_cumulative,'*g');
plot(dtm_hist.time(1:dtm_hist.len),dtm_hist.auc_cumulative(1:dtm_hist.len),'*r');
hold off
%}

% Area Under the Curve difference cumulative
%subplot(4,1,3)
%stem(ti_track(:,1), dif_auc_cumulative,'*r');

%subplot(4,1,4)


