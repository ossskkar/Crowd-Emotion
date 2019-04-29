% DESCRIPTION: 
% Find the boundaries for each zone using the clustered dataset
%
% PARAMETERS:  
% dataSet => X and Y position of each sample
% classes => class number for each row in dataSet
%              
% RETURN:      
% boundaries     => an array of cell, in each cell the boundaries data
%                   points of each zone.

function [bnds, edges] = net_inf(dataset, output)

    %Xmax = max(dataset(:,1));
    %Xmin = min(dataset(:,1)); % -50; % "-50" is an offset to cover all space in picture
    %Ymax = max(dataset(:,2)); % + 50; % "+50" is an offset to cover all space in picture
    %Ymin = min(dataset(:,2));

    % Generate datapoints covering all plane
    %x = linspace(Xmin,Xmax,200);
    %y = linspace(Ymin,Ymax,200);

    %x = dataset(:,1);
    %y = dataset(:,2);
    
    % Matrix with the zone for each datapoint covering all plane
    %s = zeros(length(x));
    
    % For every column
    %for i = 1:length(y)
        
        % Row Input 
        %input(:,1) = x; 
        %input(:,2) = y(i);
        
        % Cluster data
        %classes = net_cluster(w, input);
        
        % Find classes
        %s(:,i) = classes;
        
    %end

    % Initialize edges list
    edges = [];
    
    % For each row/column
    %for i = 1:length(x)
        
        % Check neighbors in X axis
        %neighbors = unique(s(:,i),'stable');
        
        % Add edges
        %for j = 1:(length(neighbors)-1)
            %edges = [edges; neighbors(j) neighbors(j+1)];
        %end
        
        % Check neighbors in Y axis
        %neighbors = unique(s(i,:), 'stable');
        
        % Add edges
        %for j = 1:(length(neighbors)-1)
            %edges = [edges; neighbors(j) neighbors(j+1)];
        %end
        
    %end
    
    % Makes edges unidirectional
    %edges = [edges; edges(:,2) edges(:,1)];
    
    % Remove duplicated edges
    %edges = unique(edges,'rows');
    
    % Initialize boundaries list
    bnds = {};

    % Get number of classes
    n = length(output.weight);

    % For each class (zone)
    for i = 1:n

        % Find indexes in s
        indexes_s = find(output.classes == i);
        
        % Get data points
        %data = [];
        %for j = 1:length(indexes_s)
            
            % Get the current data point indexes
            %this_idx = indexes_s(j);
            %if (mod(this_idx,length(x)) == 0)
            %    x_idx = length(x);
            %else
            %    x_idx = mod(this_idx,length(x));
            %end
            
            %y_idx = ceil(this_idx/length(x));
            
            % New data point for zone i
            %new_data = [x(x_idx) y(y_idx)];
            
            % Collect all data points
            %data = [data; new_data];
            
        %end
        
        % If any data
        if (~isempty(dataset))
            % Get boundaries of neuron 'i'
            bnd = boundary(dataset(indexes_s,1), dataset(indexes_s,2),0.1);
            
            % Save boundary data points of zone i
            %bnds{i} = dataset(bnd,:);
            bnds{i} = bnd;
        end
    end
end