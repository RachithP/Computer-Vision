function [fc] = initColorModels(img, Mask, MaskOutline, LocalWindows, BoundaryWidth, WindowWidth,K,NumWindows)
% INITIALIZAECOLORMODELS Initialize color models.  ColorModels is a struct you should define yourself.
%
% Must define a field fc: a cell array of the color confidence map for each local window.

for i = 1:NumWindows

    % Defining the window center and its range
    cy = LocalWindows(i,2);
    cx = LocalWindows(i,1);
    yRange = (cy-(WindowWidth/2)):(cy+(WindowWidth/2 - 1));
    xRange = (cx-(WindowWidth/2)):(cx+(WindowWidth/2 - 1));
    
    % Converting to L.A.B color space   
    IMG = rgb2lab(img(yRange,xRange,:));    % IMG also is taken for that particular window range
    
    % Getting ForeGround data
    [yf,xf] = find(Mask(yRange,xRange));    % Finding points which are foreground in the localwindow mask region
    foreGroundData = []; 
    
    d = bwdist(MaskOutline(yRange,xRange));
    for j = 1:length(xf)
%         if d(yf(j),xf(j)) > 3
            foreGroundData = [foreGroundData [IMG(yf(j),xf(j),1);IMG(yf(j),xf(j),2);IMG(yf(j),xf(j),3)]];
%         end
    end
    
    % ForeGround GMM fitting
    foreGMModel = fitgmdist(foreGroundData',K,'RegularizationValue',0.001,'Options',statset('MaxIter',1500,'TolFun',1e-5));
    
    % Getting Background data
    [yb,xb] = find(~Mask(yRange,xRange));
    backGroundData = [];
    for j = 1:length(xb)
        if d(yb(j),xb(j)) > 4
            backGroundData = [backGroundData [IMG(yb(j),xb(j),1);IMG(yb(j),xb(j),2);IMG(yb(j),xb(j),3)]];
        end
    end

    % Background GMM fitting
    backGMModel = fitgmdist(backGroundData',K,'RegularizationValue',0.001,'Options',statset('MaxIter',1500,'TolFun',1e-5));

%% Pixel's total Foreground probability per window
    
    datafit = reshape(IMG,WindowWidth^2,3);
    % Calculating probability mask based on new updated model foreGMModel
    % and backGMModel
    pxF = pdf(foreGMModel,datafit);
    pxB = pdf(backGMModel,datafit);
    val = pxF./(pxF+pxB);   
    pCX = reshape(val,WindowWidth,WindowWidth);
    
%% Color confidence

    localMask = Mask(yRange,xRange);
    weight = exp(-(d.^2)/(WindowWidth*0.5)^2);
    den = sum(sum(weight));
    val = sum(sum(abs(localMask - pCX).*weight));           
    
    fc(i).confidence = 1 - val/den;
    fc(i).foreGMM = foreGMModel;
    fc(i).backGMM = backGMModel;
    
    
%% Scatter plot and encompassing ellipsoid for color spaces

%     figure;
%     scatter3(foreGroundData(1,:),foreGroundData(2,:),foreGroundData(3,:),3,'r')
%     hold on
%     plotGMM(foreGMModel.mu,foreGMModel.Sigma)
%     hold off
%     figure;
%     scatter3(backGroundData(1,:),backGroundData(2,:),backGroundData(3,:),3,'b')
%     hold on
%     plotGMM(backGMModel.mu,backGMModel.Sigma)
%     hold off
%     title('LAB color space')
%     xlabel('L component')
%     ylabel('A component')
%     zlabel('B component')
%     legend('ForeGround data','BackGround data')
end
end