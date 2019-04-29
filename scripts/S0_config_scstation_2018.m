% DESCRIPTION: define all configuration variables for dataset cstation_cvpr2015

% Clean up
clear; close all; clc;
clc; disp('Step 0.1: Clean up'); 

clc; disp('Step 0.2: Define configuration variables'); 

% Original data file(s) before data conversion
config.dataFile_original{1} = '../data/scstation_02_original';
config.dataFile_original{2} = '../data/scstation_03_original';
config.dataFile_original{3} = '../data/scstation_04_original';
config.dataFile_original{4} = '../data/scstation_05_original';

config.dataFiles_len = 4;

% Emotion annotation for datasets
config.EMOTION{1}.expected_emotion = 0.5;
config.EMOTION{1}.valence_range = 1; % Maximum valence value
config.EMOTION{1}.tolerance = 1; % Tolerance factor for DTM standard deviation 

config.EMOTION{2}.expected_emotion = 0.4;
config.EMOTION{2}.valence_range = 1; % Maximum valence value
config.EMOTION{2}.tolerance = 1; % Tolerance factor for DTM standard deviation 

config.EMOTION{3}.expected_emotion = 0.4;
config.EMOTION{3}.valence_range = 1; % Maximum valence value
config.EMOTION{3}.tolerance = 1; % Tolerance factor for DTM standard deviation 

config.EMOTION{4}.expected_emotion = 0.1;
config.EMOTION{4}.valence_range = 1; % Maximum valence value
config.EMOTION{4}.tolerance = 1; % Tolerance factor for DTM standard deviation 

% Data file to be used after conversion
config.dataFile = '../data/scstation__data';

% Train and Test sets proportions
config.trainSetPortion(1) = 0.7;
config.testSetPortion(1) = 1 - config.trainSetPortion(1);
config.trainSetPortion(2) = 0.7;
config.testSetPortion(2) = 1 - config.trainSetPortion(2);
config.trainSetPortion(3) = 0.7;
config.testSetPortion(3) = 1 - config.trainSetPortion(3);
config.trainSetPortion(4) = 0.5;
config.testSetPortion(4) = 1 - config.trainSetPortion(4);

% POI file with annotations
config.POIFile_raw = '../data/scstation_POI_raw';

% POI file before data conversion
config.POIFile_original = '../data/scstation_POI_original';

% POI file after data conversion
config.POIFile = '../data/scstation_POI';

% Distance treshold for assigning POIs to tracks 
config.POIDist_treshold = 6; % in pixels
%config.POIDist_treshold_m = 1.2; % in meters

% Sliding window size for estimating motivation
config.sw_size = 0; % Assign high number to disable sliding window

% Distance threshold for adaptive sliding window for estimating motivation
config.dist_threshold = 800000000; % Assign high number to disable sliding window

% DTM file 
config.DTMFile = '../data/scstation_DTM';

% EMOTION file 
config.EMOTIONFile = '../data/scstation_EMOTION';

% LOS file 
config.LOSFile = '../data/scstation_LOS';
config.LOS_intervalSize = 60;
config.LOS_min_similarity = 2; % similarity = 0 means identical

% Frame size
config.frame_size = [500 220];

% Background image for plots
config.imgFile = '../images/scstation.png';

% Dataset parameters
config.fps = 25; 
config.fps_annotated = 1.25;
config.delta_t = 1/config.fps_annotated;

% Topology (SOM) Parameters
config.TOPOFile = '../data/scstation_TOPO';
config.TOPO.params.n_rows = 5;
config.TOPO.params.n_columns = 5;
config.TOPO.params.n_ephocs = 500;
config.TOPO.params.n_neurons = config.TOPO.params.n_rows * config.TOPO.params.n_columns;

config.TOPO.plot.s_title = 'Grand Central Station - Topology';
config.TOPO.plot.x = 720;
config.TOPO.plot.y = 480;
config.TOPO.plot.f_showData = 0;
config.TOPO.plot.f_showNet = 0;

% VOCAB file 
config.VOCABFile = '../data/scstation_VOCAB';

% Conversion factors
config.convert.speed_factor = 0.5937; %Convert speed from (pixels/delta_t) to (m/min)
config.convert.area_factor  = 0.018;  % Convert a from (pixel^2/ped) to (m^2/ped)

% Control Points of the data before conversion
config.convert.controlPoints.x = [-36 85 357 478]'; 
config.convert.controlPoints.y = [1 228 228 1]';

% Conversion Points to convert data
config.convert.conversionPoints.x = [0 0 37 37]'; 
config.convert.conversionPoints.y = [0 63 63 0]';

% Transformation form pixels to meters
config.convert.tform_p2m = ... 
    maketform('projective',[config.convert.controlPoints.x config.convert.controlPoints.y], ...
                           [config.convert.conversionPoints.x config.convert.conversionPoints.y]);

% Transformation form meters to pixel
config.convert.tform_m2p = ...
    maketform('projective', [config.convert.conversionPoints.x config.convert.conversionPoints.y], ...
                            [config.convert.controlPoints.x config.convert.controlPoints.y]);

% Save configuration file
clc; disp('Step 0.3: Save data'); 
save('../data/config','config');


% Clean on exit
clear; close all; clc;
clc; disp('Step 0: Done!');