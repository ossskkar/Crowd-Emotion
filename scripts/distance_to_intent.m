% Euclidean distance-to-intent (dti)
% d = sum((x-y).^2).^0.5

clear;
load ../data/words;

% Number of words
n_words = length(words);

% Max length of words
max_l = 0;

% Calculate max length of words
for i = 1:n_words
    n_seq = length(words(i).seq);
    if (n_seq > max_l)
        max_l = n_seq;
    end
end

% Compute distance for every word
for i = 1:n_words
    
    % Initialize distance vector
    words(i).dti = zeros(max_l,1);
    
    % Size of the current word
    n_seq = length(words(i).seq);
    
    % Final point
    %p2 = ww(words(i).seq(n_seq),:); 
    p2 = ww(words(i).seq(n_seq),1:3); 
    
    % For every state of word i
    for j = 1:n_seq
        
       % Current point
       %p1 = ww(words(i).seq(j),:);
       p1 = ww(words(i).seq(j),1:3);
       words(i).dti(j) = sum((p2-p1).^2).^0.5;
    end
end

% Compute average dti
avg_dti = zeros(max_l,1);
for i = 1:max_l
    
    sum_dti = 0;
    for j = 1:n_words
        sum_dti = sum_dti + words(j).dti(i);
    end
    avg_dti(i) = sum_dti/n_words;
end

% Plot data
x = 1:max_l;
figure
title('Euclidean Distance to Intent (DTI) - 3D')
xlabel('Time')
ylabel('distance to intent')

hold on

for i = 1:length(words)
    plot(x, words(i).dti, 'LineWidth', 0.2);
end

plot(x, avg_dti,'b', 'LineWidth', 3);
legend('word 1','word 2', 'word 3', 'mean DTI')
hold off
