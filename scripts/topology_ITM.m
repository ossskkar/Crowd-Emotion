
% DESCRIPTION: 
% Obtain training set, create ITM, train ITM, obtain boundaries and save
% data

% Clear workspace
clear_workspace;

% Create SOM Training set
create_trainingSet;
ITM_input.trainingSet = trainingSet;

% Get GNG parameters
ITM_input.params.epsilon = 1.20;
ITM_input.params.eMax    = 25;

% Create ITM
clc; disp('creating ITM'); 
ITM_output.weight = ITM_create(ITM_input.trainingSet, ITM_input.params.epsilon, ITM_input.params.eMax);

% Cluster data using ITM
clc; disp('clustering ITM');
ITM_output.classes = ...
    net_cluster(ITM_output.weight, ITM_input.trainingSet);

% Get boundaries of ITM
clc; disp('getting ITM boundaries');
[ITM_output.bnds, ITM_output.edges] = ...
    net_inf(ITM_input.trainingSet, ITM_output.weight);

% Save ITM data
clc; disp('saving data');
save ../data/PETS_ITM ITM_input ITM_output;


% -----------------------------------------------
% The function, given an initial structure containing two initial nodes,
% the trajectories for the training and two parameters epsilon and e_max,
% returns the overall nodes structure. 
% Possible using of the ITM:
% load('itm_dataset.mat')
% nodes=ITM(itm_dataset,0.1,10);
% ------------------------------------------------

function w=ITM_create(dataset,epsilon,e_max)
%Optional plot of the dataset
%for i=1:size(dataset,2)
%    plot(dataset{i}(1,:),dataset{i}(2,:),'.','Color',[rand rand rand]);
%end

% The nodes can be initialized in the following way:
%nodes{1} = struct('weight',ginput(1)');
%nodes{2} = struct('weight',ginput(1)');
nodes{1} = struct('weight',{[rand; rand]});
nodes{2} = struct('weight',{[rand; rand]});
nodes{1}.neigh{2}=nodes{2}.weight;
nodes{2}.neigh{1}=nodes{1}.weight;
%otherwise you can use [rand;rand] instead of ginput(1)' if you want to
%select randomly the first two nodes of the ITM

for k=1:length(dataset)

        % Stimulus
        Z=dataset(k,:).';
        
        % 1 - Matching
        % Find the nearest node n and the second nearest node s (with respect
        % to a given distance measure, e.g., the Euclidean distance):
        % n = argmin_i ||Z- w_i||, s = argmin_j,j=/=n, ||Z - w_j||.
        [~,n_nodes]=size(nodes);
        euc_dis=zeros(1,n_nodes);
        for h=1:n_nodes
            if(~isempty(nodes{h}))
                euc_dis(h)=sqrt((Z-nodes{h}.weight)'*(Z-nodes{h}.weight));
            else
                euc_dis(h)=Inf;
            end
        end
        [~,ind_min]=sort(euc_dis);
        clear euc_dis;
        n=ind_min(1);
        s=ind_min(2);
        
        % 2 - Reference Vector Adaption
        % Move the weight vector of the nearest node toward the stimulus
        % by a small fraction epsilon, Delta w_n=epsilon(Z-w_n)
        nodes{n}.weight=nodes{n}.weight+epsilon*(Z-nodes{n}.weight);
        %aggiorna il nuovo peso in tutti i nodi che hanno n come neigh
        for i=1:n_nodes
            if(~isempty(nodes{i}))
                [~,n_neigh_node]=size(nodes{i}.neigh);
                if(i~=n && n_neigh_node>=n &&~isempty(nodes{i}.neigh{n}))
                    nodes{i}.neigh{n}=nodes{n}.weight;
                end
            end
        end
        
        % 3 - Edge Adaption
        % (i): Create an edge connecting n and s if it does not already exist.
        [~,n_neigh_node]=size(nodes{n}.neigh);
        if(n_neigh_node<s || isempty(nodes{n}.neigh{s}))
            nodes{n}.neigh{s}=nodes{s}.weight;
            nodes{s}.neigh{n}=nodes{n}.weight;
        end
        
        % (ii): For each member m of N(n) check if w_s lies inside the Thales
        % sphere through w_n and w_m. If that is the case, remove the edge
        % connecting n and m.
        [~,col]=size(nodes{n}.neigh);
        for m=1:col
            if(~isempty(nodes{m}) && ~isempty(nodes{n}.neigh{m}) && m~=s) %escluso s?
                center1=(nodes{n}.neigh{m}+nodes{n}.weight)/2;
                ray1=sqrt((nodes{n}.neigh{m}-nodes{n}.weight)'*(nodes{n}.neigh{m}-nodes{n}.weight))/2;
                if((nodes{s}.weight(1)-center1(1))^2+(nodes{s}.weight(2)-center1(2))^2<ray1^2)
                    nodes{n}.neigh{m}=[];
                    % When deleting an edge, check m for emanating edges; if there are
                    % none, remove that node as well
                    if(isempty(nodes{m}.neigh))
                        nodes{m}=[];
                    end
                    nodes{m}.neigh{n}=[];
                end
            end
        end
        
        % 4 - Node adaptation
        % (i): If the stimulus Z lies outside the Thales sphere through w_n and
        % w_s, and outside a sphere around w_n with a given radius e_max,
        % create a new node y with w_y = Z. Connect nodes y and n.
        center2=(nodes{n}.weight+nodes{s}.weight)/2;
        ray2=sqrt((nodes{n}.weight-nodes{s}.weight)'*(nodes{n}.weight-nodes{s}.weight))/2;
        if((Z(1)-center2(1))^2+(Z(2)-center2(2))^2>ray2^2 && ...
                (Z(1)-nodes{n}.weight(1))^2+(Z(2)-nodes{n}.weight(2))^2>e_max^2)
            [~,n_nodes]=size(nodes);
            n_nodes=n_nodes+1;
            nodes{n_nodes}.weight=Z;
            nodes{n_nodes}.neigh{n}=nodes{n}.weight;
            nodes{n}.neigh{n_nodes}=nodes{n_nodes}.weight;
        end
        
        % (ii): If w_n and w_s are closer than 1/2* e_max, remove s
        [~,n_nodes]=size(nodes);
        if(sqrt((nodes{n}.weight-nodes{s}.weight)'*(nodes{n}.weight-nodes{s}.weight))<0.5*e_max && ...
                n_nodes>2) %n_nodes>2 per avere sempre almeno due nodi?
            nodes{s}=[];
        end
end

% Parse nodes weight to result
w = zeros(length(nodes),2);
for i = 1:length(nodes)
    if (~isempty(nodes{i}))
        w(i,:) = nodes{i}.weight.';
    end
end

w( ~any(w,2), : ) = [];
    
end
