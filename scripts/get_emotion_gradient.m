% DESCRIPTION: Generate gradient color matrix for emotion corresponding to
% a particular DTM histogram.

function gradient = get_emotion_gradient(emotion, dtm_hist, hist_size)

    % Initialize gradient matrix
    gradient = zeros(hist_size(2), hist_size(1),3);

    % Compute gradient map
    for hist_i = 1:hist_size(1)
        for dist_i = 1:hist_size(2)
            
            delta = (dtm_hist(hist_i) - dist_i)/ (dtm_hist(hist_i)*emotion.valence_range);
            delta(delta > 1) = 1;
            delta(delta < -1) = -1;

            e = emotion.expected_emotion + (emotion.expected_emotion * delta);
            gradient(dist_i,hist_i,:) = [1-e e 0];
        end
    end
end