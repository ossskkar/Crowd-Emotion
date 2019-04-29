% DESCRIPTION
% Creates Hidden Markov Model 
%
% Parameters:
%    seq => Sequence of observation vectors
%    states => Sequence of state vectors
%    time_scale => Time scale utilized to for time transitions
%
% Return:
%    TRANS_S => Transition matrix of states, already normalized
%    TRANS_T => Time Transition matrix of states, already normalized

%function [TRANS_S, TRANS_T, TRANS] = create_HMM(seq, states, time_scale)
function TRANS = create_HMM(seq, states, time_scale, num_states)

TRANS_S = zeros(num_states);

% Create transition matrix of states, emission matrix is ignored
[TRANS_SS, ~] = hmmestimate(ceil(abs(seq(:,:))), states(:,:));

% Move TRANS_SS to TRANS_S to maintain a uniform size for all models
TRANS_S(1:length(TRANS_SS), 1:length(TRANS_SS)) = TRANS_SS(1:length(TRANS_SS), 1:length(TRANS_SS));

% Get number of states
%num_states = length(TRANS_S);

% Initialize time transition matrix of states
TRANS_T = zeros(num_states, num_states, length(time_scale));
TRANS = zeros(num_states, num_states, length(time_scale));

% Get transition times
trans_time = [];
count = 0;
for t = 2:length(states)
    % Find time scale index
    ts_idx = min(find(time_scale >= t));
    
    % Update time transition matrix of states
    TRANS_T(states(t-1), states(t), ts_idx) = TRANS_T(states(t-1), states(t), ts_idx) + 1;
end

% Normalize TRANS_T
for t = 1:length(time_scale)
    for i = 1:num_states
        new_row = zeros(1,num_states);
        for j = 1:num_states
            if (TRANS_T(i,j,t) ~= 0)
                new_row(j) = TRANS_T(i,j,t) / sum(TRANS_T(i,:,t));
            end
        end
        TRANS_T(i,:,t) = new_row;
    end

end

% Unify and Normalize TRANS
for t = 1:length(time_scale)
    
    % Unify matrices
    TRANS(:,:,t) = TRANS_T(:,:,t) .*  TRANS_S;
    
    % Normalize
    for i = 1:num_states
        new_row = zeros(1,num_states);
        for j = 1:num_states
            if (TRANS(i,j,t) ~= 0)
                new_row(j) = TRANS(i,j,t) / sum(TRANS(i,:,t));
            end
        end
        TRANS(i,:,t) = new_row;
    end

end

end