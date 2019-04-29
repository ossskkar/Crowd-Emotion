% DESCRIPTION: 
% Obtain training set, create GNG, train GNG, obtain boundaries and save
% data

% Clear workspace
clear_workspace;

% Create SOM Training set
create_trainingSet;
GNG_input.trainingSet = trainingSet;

% Get GNG parameters
% Parameters
GNG_input.params.N         = 5;
GNG_input.params.MaxIt     = 20;
GNG_input.params.L         = 50;
GNG_input.params.epsilon_b = 0.2;
GNG_input.params.epsilon_n = 0.005;
GNG_input.params.alpha     = 0.5;
GNG_input.params.delta     = 0.995;
GNG_input.params.T         = 50;

% Create GNG
clc; disp('creating GNG'); 
GNG = GNG_create(GNG_input.trainingSet, GNG_input.params, false);

% GNG neurons weights
GNG_output.weight = GNG.w;

% Cluster data using GNG
clc; disp('clustering GNG');
GNG_output.classes = ...
    net_cluster(GNG_output.weight, GNG_input.trainingSet);

% Get boundaries of GNG
clc; disp('getting GNG boundaries');
[GNG_output.bnds, GNG_output.edges] = ...
    net_inf(GNG_input.trainingSet, GNG_output.weight);

% Save growing neural gas
clc; disp('saving data');
save ../data/PETS_GNG GNG GNG_input GNG_output;



%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPML111
% Project Title: Growing Neural Gas Network in MATLAB
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%

function net = GNG_create(X, params, PlotFlag)

    if ~exist('PlotFlag', 'var')
        PlotFlag = false;
    end

    % Load Data
    
    nData = size(X,1);
    nDim = size(X,2);

    X = X(randperm(nData), :);

    Xmin = min(X);
    Xmax = max(X);

    % Parameters

    N = params.N;
    MaxIt = params.MaxIt;
    L = params.L;
    epsilon_b = params.epsilon_b;
    epsilon_n = params.epsilon_n;
    alpha = params.alpha;
    delta = params.delta;
    T = params.T;

    % Initialization

    Ni = 2;

    w = zeros(Ni, nDim);
    for i = 1:Ni
        w(i,:) = unifrnd(Xmin, Xmax);
    end

    E = zeros(Ni,1);

    C = zeros(Ni, Ni);
    t = zeros(Ni, Ni);

    % Loop

    nx = 0;

    for it = 1:MaxIt
        for l = 1:nData
            % Select Input
            nx = nx + 1;
            x = X(l,:);

            % Competion and Ranking
            d = pdist2(x, w);
            [~, SortOrder] = sort(d);
            s1 = SortOrder(1);
            s2 = SortOrder(2);

            % Aging
            t(s1, :) = t(s1, :) + 1;
            t(:, s1) = t(:, s1) + 1;

            % Add Error
            E(s1) = E(s1) + d(s1)^2;

            % Adaptation
            w(s1,:) = w(s1,:) + epsilon_b*(x-w(s1,:));
            Ns1 = find(C(s1,:)==1);
            for j=Ns1
                w(j,:) = w(j,:) + epsilon_n*(x-w(j,:));
            end

            % Create Link
            C(s1,s2) = 1;
            C(s2,s1) = 1;
            t(s1,s2) = 0;
            t(s2,s1) = 0;

            % Remove Old Links
            C(t>T) = 0;
            nNeighbor = sum(C);
            AloneNodes = (nNeighbor==0);
            C(AloneNodes, :) = [];
            C(:, AloneNodes) = [];
            t(AloneNodes, :) = [];
            t(:, AloneNodes) = [];
            w(AloneNodes, :) = [];
            E(AloneNodes) = [];

            % Add New Nodes
            if mod(nx, L) == 0 && size(w,1) < N
                [~, q] = max(E);
                [~, f] = max(C(:,q).*E);
                r = size(w,1) + 1;
                w(r,:) = (w(q,:) + w(f,:))/2;
                C(q,f) = 0;
                C(f,q) = 0;
                C(q,r) = 1;
                C(r,q) = 1;
                C(r,f) = 1;
                C(f,r) = 1;
                t(r,:) = 0;
                t(:, r) = 0;
                E(q) = alpha*E(q);
                E(f) = alpha*E(f);
                E(r) = E(q);
            end

            % Decrease Errors
            E = delta*E;
        end

        % Plot Results
        if PlotFlag
            figure(1);
            %PlotResults(X, w, C);
            plotgng(X, w, C);
            pause(0.01);
        end
    end

    % Export Results
    net.w = w;
    net.E = E;
    net.C = C;
    net.t = t;
    
end