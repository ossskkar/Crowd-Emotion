% DESCRITPION: Define Levels of Service.

% Clean up
clear; close all; clc;
clc; disp('Step 9.1: Clean up');

% Load data
clc; disp('Step 9.2: Load data');
load('../data/config');
load(config.dataFile);

% Backup routine
data.backup = strcat("Backup made on ",mfilename);
save(strcat(config.dataFile,"_bk"), 'data');

% Define data.LOS
clc; disp('Step 9.3: Define data.LOS');

% Maximum data.LOS permitted
data.LOS.max_LOS = 100;

data.LOS.label{1}   = 'A';
data.LOS.color{1}   = [0.4 0.7 1.0];
data.LOS.percent{1} = 0.23;
data.LOS.limits{1}  = [0 round(data.LOS.max_LOS * data.LOS.percent{1},2)];
%data.LOS.limits{6} = [round(data.LOS.limits{5}(2),2)+0.1 round(data.LOS.limits{5}(2) +  data.LOS.max_LOS * data.LOS.percent{6},2)];

data.LOS.label{2}   = 'B';
data.LOS.color{2}   = [0.7 1.0 0.4];
data.LOS.percent{2} = 0.10;
data.LOS.limits{2}  = [round(data.LOS.limits{1}(2),2)+0.1 round(data.LOS.limits{1}(2) +  data.LOS.max_LOS * data.LOS.percent{2},2)];
%data.LOS.limits{5} = [round(data.LOS.limits{4}(2),2)+0.1 round(data.LOS.limits{4}(2) +  data.LOS.max_LOS * data.LOS.percent{5},2)];

data.LOS.label{3}   = 'C';
data.LOS.color{3}   = [1.0 1.0 0.4];
data.LOS.percent{3} = 0.16;
data.LOS.limits{3}  = [round(data.LOS.limits{2}(2),2)+0.1 round(data.LOS.limits{2}(2) +  data.LOS.max_LOS * data.LOS.percent{3},2)];
%data.LOS.limits{4} = [round(data.LOS.limits{3}(2),2)+0.1 round(data.LOS.limits{3}(2) +  data.LOS.max_LOS * data.LOS.percent{4},2)];

data.LOS.label{4}   = 'D';
data.LOS.color{4}   = [1.0 0.7 0.4];
data.LOS.percent{4} = 0.17;
data.LOS.limits{4}  = [round(data.LOS.limits{3}(2),2)+0.1 round(data.LOS.limits{3}(2) +  data.LOS.max_LOS * data.LOS.percent{4},2)];
%data.LOS.limits{3} = [round(data.LOS.limits{2}(2),2)+0.1 round(data.LOS.limits{2}(2) +  data.LOS.max_LOS * data.LOS.percent{3},2)];

data.LOS.label{5}   = 'E';
data.LOS.color{5}   = [1.0 0.4 0.4];
data.LOS.percent{5} = 0.16;
data.LOS.limits{5}  = [round(data.LOS.limits{4}(2),2)+0.1 round(data.LOS.limits{4}(2) +  data.LOS.max_LOS * data.LOS.percent{5},2)];
%data.LOS.limits{2} = [round(data.LOS.limits{1}(2),2)+0.1 round(data.LOS.limits{1}(2) +  data.LOS.max_LOS * data.LOS.percent{2},2)];

data.LOS.label{6}   = 'F';
data.LOS.color{6}   = [1.0 0.6 0.6];
data.LOS.percent{6} = 0.18;
data.LOS.limits{6}  = [round(data.LOS.limits{5}(2),2)+0.1 round(data.LOS.limits{5}(2) +  data.LOS.max_LOS * data.LOS.percent{6},2)];
%data.LOS.limits{1}  = [0 round(data.LOS.max_LOS * data.LOS.percent{1},2)];

data.LOS.len = length(data.LOS.label);

% Create Colormap for data.LOS
data.LOS.colormap_size = [64, 3];
data.LOS.colormap = zeros(data.LOS.colormap_size);

% For each data.LOS
for li = 1:data.LOS.len
    
    % For R,G,B
    for ci = 1:3
        
        if (li == 1)
            % Compute indexes in colormap
            data.LOS.cmap_idxs(li,:) = [1, int32(data.LOS.colormap_size(1)*data.LOS.percent{li})];
            
            % Compute color
            data.LOS.colormap(data.LOS.cmap_idxs(li,1):data.LOS.cmap_idxs(li,2),ci) = data.LOS.color{li}(ci);
        else
            % Compute indexes in colormap
            data.LOS.cmap_idxs(li,:) = [data.LOS.cmap_idxs(li-1,2)+1, data.LOS.cmap_idxs(li-1,2)+int32(data.LOS.colormap_size(1)*data.LOS.percent{li})];
            
            % Compute color
            data.LOS.colormap(data.LOS.cmap_idxs(li,1):data.LOS.cmap_idxs(li,2),ci) = ...
                linspace(data.LOS.color{li-1}(ci), data.LOS.color{li}(ci), data.LOS.cmap_idxs(li,2) - data.LOS.cmap_idxs(li,1) + 1);
        end
    end    
end

% Save data
clc; disp('Step 9.4: Save data');
save(config.dataFile, 'data');

% Clean on exit
clear; close all; clc;
clc; disp('Step 9: Done!');
