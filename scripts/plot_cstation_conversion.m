% DESCRIPTION: Plot data conversion in a 3-step figure

%function plot_net(data)
    clear; close all; clc;
    load('../data/config');
    load(config.dataFile);
    load(config.TOPOFile);
    
    % Control Points of the data before conversion
    controlPoints.x = [-36 85 357 478]';
    controlPoints.y = [1 228 228 1]';
    
    % Conversion Points to convert data
    conversionPoints.x = [0 0 37 37]';
    conversionPoints.y = [0 63 63 0]';
    
    tform = maketform('projective',[controlPoints.x controlPoints.y], [conversionPoints.x conversionPoints.y]);
    
    % Convert data to real size
    [convertedPoints.x, convertedPoints.y] = tformfwd(tform, controlPoints.x, controlPoints.y);
    convertedPoints.x = round(convertedPoints.x,2);
    convertedPoints.y = round(convertedPoints.y,2);
    
    
    [convertedData(:,1), convertedData(:,2)] = tformfwd(tform, TOPO.trainSet(:,1), TOPO.trainSet(:,2));
    convertedData(:,1) = round(convertedData(:,1),2);
    convertedData(:,2) = round(convertedData(:,2),2);
    
    % Open figure in fullscreen mode
    figure;
    pause(0.00001);
    frame_h = get(handle(gcf),'JavaFrame');
    set(frame_h,'Maximized',1);

    %==== SUBPLOT #1: Environment and reference frame ====%
    subplot(1,3,1);
    
    % Plot background image
    img = imread(config.imgFile);
    imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
    set(gca,'YDir','normal')
    hold on

    % Plot Control Points
    plot([controlPoints.x; controlPoints.x(1,:)], [controlPoints.y; controlPoints.y(1,:)], 'r', 'LineWidth', 6);
    scatter(controlPoints.x, controlPoints.y, 400, 'MarkerFaceColor', [1 1 0]);
    scatter(controlPoints.x, controlPoints.y, 200, 'MarkerFaceColor', [1 0 0]);
    
    hold off
    
    %==== SUBPLOT #2: Reference frame and original data ====%
    subplot(1,3,2);
    
    img = imread(config.imgFile);
    imagesc([0 config.frame_size(1)], [0 config.frame_size(2)], img);
    set(gca,'YDir','normal')
    
    hold on
    
    % Plot data
    scatter(TOPO.trainSet(:,1), TOPO.trainSet(:,2), 10, 'g');
    
    % Plot Control Points
    plot([controlPoints.x; controlPoints.x(1,:)], [controlPoints.y; controlPoints.y(1,:)], 'r', 'LineWidth', 6);
    scatter(controlPoints.x, controlPoints.y, 400, 'MarkerFaceColor', [1 1 0]);
    scatter(controlPoints.x, controlPoints.y, 200, 'MarkerFaceColor', [1 0 0]);
    
    hold off
    
    %==== SUBPLOT #3: Reference frame and converted data ====%
    subplot(1,3,3);
    hold on
    
    % Plot converted data
    scatter(convertedData(:,1), convertedData(:,2), 10, 'g');
    
    % Plot Converted Points
    plot([convertedPoints.x; convertedPoints.x(1,:)], [convertedPoints.y; convertedPoints.y(1,:)], 'r', 'LineWidth', 6);
    scatter(convertedPoints.x, convertedPoints.y, 400, 'MarkerFaceColor', [1 1 0]);
    scatter(convertedPoints.x, convertedPoints.y, 200, 'MarkerFaceColor', [1 0 0]);
    
    axis([-5 45 -5 90])
    
    
    hold off
    
    
    