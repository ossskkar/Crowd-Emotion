load ../data/PETS_train_test_sets;

dataset = testSet.set3.tracks;

n = length(dataset);

figure;

% Image for background
img = imread('../images/view_001b.jpg');
imagesc([0 768], [0 576], img);
hold on;

for i = 1:n
    this_track = dataset{i};
    [ts tn] = size(this_track);
    for j = 2:6:ts
    
        x(j) = this_track(j,2);
        y(j) = this_track(j,3);
        
        u(j) = (this_track(j,2) - this_track(j-1,2))*.4;
        v(j) = (this_track(j,3) - this_track(j-1,3))*.4;
    end
    quiver(x, -y, u, -v);
end

hold off;