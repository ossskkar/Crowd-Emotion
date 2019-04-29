% Plot Cosine Similarity

% Time on x axis
tt = unique(dataset.raw(:,1))

figure
plot(tt, sv.cos_sim(:,1), 'b', tt, sv.cos_sim(:,2), 'r--', 'LineWidth',2)
grid on
