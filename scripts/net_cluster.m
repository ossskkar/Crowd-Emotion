% DESCRIPTION
% Cluster input data into classes of net.

function output = net_cluster(w, input)

    % Cluster dataset
    output = knnsearch(w,input);

end