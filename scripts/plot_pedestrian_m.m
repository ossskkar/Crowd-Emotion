% DESCRIPTION: Plot topology in colored zones

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% PLOT MEAN PEDESTRIAN EMOTION MSE
mean_track_emotion_mse = zeros(1,config.dataFiles_len);



figure;
hold on;
b = []
color = ["blue", "green", "cyan", "red"];
for di = 1:config.dataFiles_len
    dataset = data.testSet{di};
    mean_track_emotion_mse(di) = mean(dataset.tracks_emotion_mse(~isnan(dataset.tracks_emotion_mse)))
    b(di) = bar(di, mean_track_emotion_mse(di), 'FaceColor', color(di));
end

hold off;
alpha(0.5);
xticks('');
xlabel('Test Sets', 'FontSize', 20);
ylabel('MSE', 'FontSize', 20);
legend([b(:)], 'Non-peak hours', 'Morning peak hours', 'Evening peak hours', 'Panic', ...
    'FontSize', 15);

box('on')
print('../figures/scstation_pedestrian_emotion_mse','-dpng');


% PLOT MEAN PEDESTRIAN MOTIVATION ESTIMATION ACCURACY 
mean_tracks_m_est_accuracy = zeros(1,config.dataFiles_len);

figure;
hold on;
b = []
color = ["blue", "green", "cyan", "red"];
for di = 1:config.dataFiles_len
    dataset = data.testSet{di};
    mean_tracks_m_est_accuracy(di) = mean(dataset.tracks_m_est_accuracy);
    b(di) = bar(di, mean_tracks_m_est_accuracy(di), 'FaceColor', color(di));
end

hold off;
alpha(0.5);
xticks('');
xlabel('Test Sets', 'FontSize', 20);
ylabel('Accuracy', 'FontSize', 20);
legend([b(:)], 'Non-peak hours', 'Morning peak hours', 'Evening peak hours', 'Panic', ...
    'FontSize', 15);

box('on')
print('../figures/scstation_pedestrian_m_est','-dpng');
