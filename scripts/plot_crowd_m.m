% DESCRIPTION: Plot topology in colored zones

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

% PLOT MEAN PEDESTRIAN MOTIVATION ESTIMATION ACCURACY 
mean_crowd_m_est_accuracy = zeros(data.TOPO.n_neurons,config.dataFiles_len);


for i = 1:length(data.testSet)
    for j = 1:data.TOPO.n_neurons
        len = length(data.testSet{i}.crowd_m_est(:,j)) - 60;
        if (i == 4)
            mean_crowd_m_est_accuracy(j,i) = nnz((data.testSet{i}.crowd_m_est(1:len,j) == 4) | (data.testSet{i}.crowd_m_est(1:len,j) == 3));
        else
            mean_crowd_m_est_accuracy(j,i) = nnz(data.testSet{i}.crowd_m_est(1:len,j) == data.testSet{i}.crowd_m_groundtruth(1:len,j));
        end
        mean_crowd_m_est_accuracy(j,i) = mean_crowd_m_est_accuracy(j,i)/len;      
    end
end


color = ["b", "g", "c", "r"];

figure;
hold on

for i = 1:length(data.testSet)
    for j = 1:data.TOPO.n_neurons
        k = (i-1)*30 + j;
        plot([k k], [0 mean_crowd_m_est_accuracy(j,i)],color(i), 'LineWidth', 2);
        scatter(k, mean_crowd_m_est_accuracy(j,i), strcat(color(i),'s'), 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', color(i), 'LineWidth', 2);
    end
end

% Formating 
%xlabel('Sub-regions');
ylabel('Accuracy');
yticks([0 0.2 0.4 0.6 0.8 1.0]);
xticks([12.5 42.5 72.5 102.5]);
xticklabels({'Non-peak Hours', 'Morning Peak Hours', 'Evening Peak Hours', 'Panic'});
alpha(0.5);
set(gca,'fontsize',20)
set(gca,'color','none')
set(0,'DefaultAxesColor','none')
box on
print('../figures/crowd_m_accuracy_1','-dpng');
