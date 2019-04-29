% DESCRIPTION: Plot Level of Service for one zone

% Clean up
clear; close all; clc;

% Load data
load('../data/config');
load(config.dataFile);
load(config.TOPOFile);

% Data to use
dataset = data.trainSet;

zi = 1;

plot(dataset.mean_emotion_per_zone(:,zi), 'b')
