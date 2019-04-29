clear;

load ../data/CSTATION_DATASET_1fps

n = length(trks);

dataset(:,4) = -dataset(:,4);

tracks = {};
for i = 1:n
    tracks{i} = [trks(i).t trks(i).x -trks(i).y];
end

t = unique(dataset(:,1));

for i = 1:n
    im = ismember(tracks{i}(:,1),t);
    tracks{i} = tracks{i}(im,:);
end

clear i im n t;
save ../data/CSTATION_DATASET_1fps;
