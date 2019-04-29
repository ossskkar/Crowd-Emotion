% DESCRIPTION: Implementation of Kalman filter to estimate position
% of pedestrians

function x = run_KF(KF, z)

    % Filtering loop
    for t=1:length(z)
        
        % Update
        [KF.x, KF.P] = kf_update(KF.x_p, KF.P_p, z(:,t), KF.H, KF.Q);
        
        % Prediction 
        [KF.x_p, KF.P_p] = kf_predict(KF.x, KF.P, KF.F, KF.R);

        % Store prediction
        x(:, t) = KF.x;
    end
  
end
 
 function [x_p, P_p] = kf_predict(x_u, P_u, F, R)
    x_p = F * x_u; % P-1
    P_p = F * P_u *F' + R; % P-2
 end
 
 function [x_u, P_u] = kf_update(x_p, P_p, z, H, Q)
    y = z - H*x_p; % u-1
    S = H*P_p*H'+Q; % u-2
    K = P_p * H' / S;

    x_u = x_p + K *y;
    P_u = (eye(size(P_p)) - K * H) * P_p;
 end
 
 
 
 
 
 