% DESCRIPTION: Initialize Kalman Filter 

function KF = create_KF()

    % Time difference
    KF.delta = 0.1;

    % Dynamic model
    KF.F = [1 0 KF.delta  0; 
         0 1 0      KF.delta; 
         0 0 1      0
         0 0 0      1];

    % Observation model
    KF.H = [1 0 0 0; 0 1 0 0];

    % Dynamic noise
    KF.R = eye(4)*0.001; 

    % Observation noise
    KF.Q = eye(2);

    % Initial state
    KF.x = [0; 0; 0; 0;];

    % Priori
    KF.P = eye(4)*5;

    % Initial prediction
    [KF.x_p, KF.P_p] = kf_predict(KF.x, KF.P, KF.F, KF.R);

end

function [x_p, P_p] = kf_predict(x_u, P_u, F, R)
    x_p = F * x_u; % P-1
    P_p = F * P_u *F' + R; % P-2
 end
 