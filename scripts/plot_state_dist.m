load ../data/PETS_train_test_sets;

% Create SOM for state vector
SOM_input.trainingSet = [trainSet.set1.sv.unified; trainSet.set2.sv.unified];
SOM_sv;

% Get classes for all datasets (training/testing sets)
trainSet.set1.sv.unified_classes = vec2ind(SOM(trainSet.set1.sv.unified.'));
trainSet.set2.sv.unified_classes = vec2ind(SOM(trainSet.set2.sv.unified.'));
testSet.set1.sv.unified_classes = vec2ind(SOM(testSet.set1.sv.unified.'));
testSet.set2.sv.unified_classes = vec2ind(SOM(testSet.set2.sv.unified.'));

% Plot states on all sets
figure

subplot(2,2,1);
bar(trainSet.set1.sv.unified_classes)

subplot(2,2,2);
bar(trainSet.set2.sv.unified_classes)

subplot(2,2,3);
bar(testSet.set1.sv.unified_classes)

subplot(2,2,4);
bar(testSet.set2.sv.unified_classes)