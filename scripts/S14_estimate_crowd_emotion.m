% DESCRIPTION: Compute the LOS for each zone at every time instance t

% Clean up
clear; close all; clc;
clc; disp('Step 14.1: Clean up'); 

% Load data
clc; disp('Step 14.2: Load data'); 
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% For test sets
for trainTest = 2

    % For each training/test set
    for set_i = 1:max([length(data.trainSet) length(data.testSet)])

        % Select a dataset to process
        if (trainTest == 1)
            dataset = data.trainSet{set_i};
        else
            dataset = data.testSet{set_i};
        end
        
        % STEP #1: Compute crowd emotion labels (CUMULATIVE)
        
        % Initialize 
        dataset.crowd_emotion_est_cum = zeros(length(dataset.crowd_state), config.TOPO.params.n_neurons);

        % For every time ti, use an LOS interval size for observation
        for ti = config.LOS_intervalSize+1:length(dataset.crowd_state)

            % For each zone zi
            for zi = 1:config.TOPO.params.n_neurons
                
                % Update status
                disp(['Step 14.5: Processing zone ', num2str(zi), ' time ', num2str(ti)]); 

                % Observation data
                obs.start = ti-config.LOS_intervalSize;
                obs.end = ti;
                obs.y = dataset.crowd_state(obs.start:obs.end,zi);
                
                % Prediction data
                pred.mdl_idx = dataset.crowd_m_bmu{obs.start,zi}.mdl_idx;
                pred.start = dataset.crowd_m_bmu{obs.start,zi}.start;
                pred.end = dataset.crowd_m_bmu{obs.start,zi}.end;
                
                if (pred.end ~= 0)
                    pred.y = data.trainSet{pred.mdl_idx}.LOS.ypred{zi}(pred.start(pred.mdl_idx):pred.end(pred.mdl_idx));
                
                    % Compute trapezoidal area under the curve of expectation
                    pred.auc = trapz(pred.y(pred.y~=0));
                    %auc_exp = trapz(ypred(y~=0));

                    % Compute trapezoidal area under the curve of observation
                    obs.auc = trapz(obs.y(obs.y~=0));
                    %auc_obs = trapz(y(y~=0));

                    % Compute deviation
                    auc_dev = (pred.auc - obs.auc) / pred.auc;
                    %auc_dev = (auc_exp - auc_obs) / auc_exp; 
                
                    % Compute emotion label
                    label = dataset.EMOTION.expected_emotion + (dataset.EMOTION.expected_emotion * auc_dev);
                else
                    % Compute emotion label
                    label = dataset.EMOTION.expected_emotion;
                end
                    
                if (isnan(label))
                    label = 0;
                elseif (label > 1)
                    label = 1;
                elseif (label < 0)
                    label = 0;
                end
 
                dataset.crowd_emotion_est_cum(ti,zi) = label;
                %[auc_exp auc_obs auc_dev dataset.crowd_emotion_label_cum(ti,zi)]
                
                %{
                figure
                subplot(1,3,1);
                hold on
                plot(obs.y,'g');
                plot(pred.y,'b');
                hold off
                
                subplot(1,3,2);
                hold on
                plot(obs.auc,'*g');
                plot(pred.auc,'*b');
                hold off
                
                subplot(1,3,3);
                hold on
                plot(dataset.crowd_emotion_est_cum(ti,zi), '*g');
                plot(dataset.mean_emotion_per_zone(ti,zi), '*b');
                hold off
                %}
                
            end
        end
        
        
        % STEP #4: Compute crowd emotion labels (INSTANTANEOUS)
        %{
        % Initialize 
        dataset.crowd_emotion_label_ins = zeros(length(dataset.crowd_state), config.TOPO.params.n_neurons);

        % For every time ti
        for ti = 1:length(dataset.crowd_state)

            % For each zone zi
            for zi = 1:config.TOPO.params.n_neurons

                y = dataset.crowd_state(ti,zi);
                ypred = dataset.LOS.ypred{zi}(ti);

                % Update status
                disp(['Step 10.6: Processing zone ', num2str(zi), ' time ', num2str(ti)]); 

                % Compute difference between expectation and observation
                diff = (ypred - y)/ypred;

                % Compute emotion label
                label = 0.5 + (0.5 * diff);

                if (isnan(label))
                    label = 0;
                elseif (label > 1)
                    label = 1;
                elseif (label < 0)
                    label = 0;
                end

                dataset.crowd_emotion_label_ins(ti,zi) = label;
            end
        end
        %}
    
      % Update a dataset
        if (trainTest == 1)
            data.trainSet{set_i} = dataset;
        else
            data.testSet{set_i} = dataset;
        end
    end
end

% Save data
clc; disp('Step 14.6: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 14: Done!');

%{
immse(data.testSet{1}.crowd_emotion_est_cum(61:1931,1), data.testSet{1}.mean_emotion_per_zone(61:1931,1))
hold on
plot(data.testSet{1}.crowd_emotion_est_cum(61:1931,1), 'b')
plot(data.testSet{1}.mean_emotion_per_zone(61:1931,1),'g')
hold off
%}