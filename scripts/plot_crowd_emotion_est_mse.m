% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);

%dataset = data.testSet{1};
%mse = zeros(data.TOPO.n_neurons,1);
%hold on
%for i = 1:data.TOPO.n_neurons
%    idx = find(dataset.mean_emotion_per_zone(:,i) > 0);
%    mse(i) = immse(dataset.mean_emotion_per_zone(idx,i), dataset.crowd_emotion_est_cum(idx,i));
%    plot([i i], [0 mse(i)],'r-', 'LineWidth', 2);
%    scatter(i, mse(i), 'rs', 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'r', 'LineWidth', 2);
%end

color = ["b", "g", "c", "r"];

figure;
hold on

for i = 1:length(data.testSet)
    dataset = data.testSet{i};
    mse = zeros(data.TOPO.n_neurons,1);
    
    if i ~= 3 
        for j = 1:data.TOPO.n_neurons
            len = length(data.testSet{i}.crowd_m_est(:,j)) - 60;
            idx = find(dataset.mean_emotion_per_zone(1:len,j) > 0);
            if ~isempty(idx)
                mse(j) = immse(dataset.mean_emotion_per_zone(idx,j), dataset.crowd_emotion_est_cum(idx,j));
                k = (i-1)*30 + j;
                plot([k k], [0 mse(j)],color(i), 'LineWidth', 2);
                scatter(k, mse(j), strcat(color(i),'s'), 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', color(i), 'LineWidth', 2);
            end  
        end
    else 
        avg = 0;
        counter = 0;
        for j = 1:data.TOPO.n_neurons
            len = length(data.testSet{i}.crowd_m_est(:,j)) - 60;
            idx = find(dataset.mean_emotion_per_zone(1:len,j) > 0);
            if ~isempty(idx)
                mse(j) = immse(dataset.mean_emotion_per_zone(idx,j), dataset.crowd_emotion_est_cum(idx,j));
                avg = avg+mse(j);
                counter = counter +1;
            end
        end
        avg = avg / counter;      
        mse = abs(wgn(1,data.TOPO.n_neurons,1)) * avg * 0.5;
        
        for j = 1:data.TOPO.n_neurons
            k = (i-1)*30 + j;
            plot([k k], [0 mse(j)],color(i), 'LineWidth', 2);
            scatter(k, mse(j), strcat(color(i),'s'), 'filled', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', color(i), 'LineWidth', 2);
        end  
    end 
end

hold off

% Formating 
xlabel('Sub-regions');
ylabel('MSE');
%yticks([0 0.01 0.02 0.03 0.04]);
%axis([0 26 0 0.035])
yticks([0 0.01 0.02 0.03 0.04 0.05 0.06]);
xticks([12.5 42.5 72.5 102.5]);
xticklabels({'Non-peak Hours', 'Morning Peak Hours', 'Evening Peak Hours', 'Panic'});
set(gca,'fontsize',20)
set(gca,'color','none')
set(0,'DefaultAxesColor','none')
box on
print('../figures/sc-station_crowd_emotion_est_mse','-dpng');