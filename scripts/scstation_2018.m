% %======== STEP 0: Configure Environment %========
%
% Clean workspace and define all configuration variables
%

%clc; disp('Step 0: Configure Environment'); 
%S0_config_scstation_2018;

% *--------------------------------------------------------------------* %
%                                                                        %
%                             TRAINING PHASE                             %
%                                                                        %
% *--------------------------------------------------------------------* %


% %======== STEP 1: Preprocess Data %======== 
%
% Create train and test sets, convert data from pixels to meters
%
%clc; disp('Step 1: Preprocess Data'); 
%S1_preprocess_data;

% %======== STEP 2: Generate Points of Interest (POI) %========
%
% Take annotations of POIs and generate POIs data
%
%disp('Step 2: Generate POI'); 
% 2.1. Create jpg image to indicate walls and attractors

% 2.2. Run social force simulator to compute attractors points, boundaries
%      and direction fields

% 2.3. Format data generated from simulator to be used here
%format_attractors;
% 2.4. Run 'S2_generate_POIs.m' to format data. Output is saved
%      as 'attractors_cstation_cvpr2015.mat'
%S2_generate_POI;

% %======== STEP 3: Label Tracks by POI Pair %======== 
%
% Assign POI pair label to tracks based on the origin-destination POIs
%
%disp('Step 3: Label Tracks by POI Pair'); 
%S3_label_tracks_POI_pair;

% %======== STEP 4: Compute Motivation A Priori %======== 
%
%disp('Step 4: Compute Motivation A Priori'); 
%S4_compute_motivation_data;

% %======== STEP 5: Compute Distance-to-Motivation (DTM) %======== 
%
%disp('Step 5: Compute DTM'); 
%S5_compute_DTM;

% %======== STEP 6: Learn Topology %======== 
%
% Use training data (raw) to train a SOM to learn the environment's
% topology
%
%disp('Step 6: Learn Topology'); 
%S6_learn_TOPO;

% %======== STEP 7: Generate Emotion Labels %======== 
%
% Generate emotion labels for each track in training set
%
%disp('Step 7: Generate Emotion Labels'); 
%S7_label_tracks_emotion;

% %======== STEP 8: Generate Vocabularies (VOCAB) %======== 
% NOT USED ANYMORE
% Generate the vocabulary of words for each POI pair and compute the 
% mean-distance-traveled per zone (MDT)
%
%disp('Step 8: Generate Vocabularies'); 
%S8_generate_VOCAB;

% %======== STEP 9: Define Levels of Service (LOS) %======== 
%
% Levels of Service are the feature used to represent crowd states
%
%disp('Step 9: Define Levels of Service'); 
%S9_define_LOS;

% %======== STEP 10: Compute Crowd States %======== 
%
% Compute the LOS for each zone at every time instance t
%

%disp('Step 10: Compute Crowd States'); 
%S10_compute_crowd_states;


% *--------------------------------------------------------------------* %
%                                                                        %
%                              TESTING PHASE                             %
%                                                                        %
% *--------------------------------------------------------------------* %


% %======== STEP 11: Estimate Crowd motivation %======== 
%
%S11_estimate_crowd_motivation;
% 

% %======== STEP 12: Estimate Crowd motivation %======== 
%
%disp('Step 12: Estimate Individual Motivations'); 
%S12_estimate_individual_motivation;

% %======== STEP 13: Estimate Individual Emotions %======== 
%
%disp('Step 13: Estimate Individual Emotions'); 
%
%S13_estimate_individual_emotions;

% %======== STEP 14: Estimate Crowd Emotions %======== 
%
%disp('Step 14: Estimate Crowd Emotions'); 

