function data = getDensity(data)

% DESCRIPTION: given a set of tracks, compute the density (in people per pixel) for
%              each track at every time instant.


% Get time vector
t = unique(data.raw(:,1));

% Initialize density vector
d = zeros(length(t),3);

% Update time 
d(:,1) = t;

% Area of environment
area = ((data.inf.frame_size(1)*data.inf.meter_per_pixel) * (data.inf.frame_size(2)*data.inf.meter_per_pixel)); 

% For each time instant t
for i = 1:length(t)
    
    % Update status
    display(strcat('Computing density at time t=', num2str(t(i))));
    
    % Update data
    d(i,2) = length(find(data.raw(:,1) == t(i)))/area; % density
    d(i,3) = length(find(data.raw(:,1) == t(i))); % people count
end

% Update density data
data.density = d;

end
