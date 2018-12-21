function [LocalWindows,flow] = localFlowWarp(WarpedPrevFrame, CurrentFrame, LocalWindows, Mask, Width)
% LOCALFLOWWARP Calculate local window movement based on optical flow between frames.

flowObject = opticalFlowFarneback;

greyWarpedPrevFrame = rgb2gray(WarpedPrevFrame);
greyCurrentFrame = rgb2gray(CurrentFrame);

flow = estimateFlow(flowObject,greyWarpedPrevFrame);
flow = estimateFlow(flowObject,greyCurrentFrame);

% figure;
% imshow(greyCurrentFrame) 
% hold on
% plot(flow,'DecimationFactor',[5 5],'ScaleFactor',5)
% hold off

% Caclulating the average velocity of region inside the contour for each
% window
% NewLocalWindows = zeros(size(LocalWindows));
for i =1:length(LocalWindows)
    cx = LocalWindows(i,1);
    cy = LocalWindows(i,2);
    yRange = (cy-(Width/2)):(cy+(Width/2 - 1));
    xRange = (cx-(Width/2)):(cx+(Width/2 - 1));
    
    fVx = flow.Vx(yRange,xRange);
    fVy = flow.Vy(yRange,xRange);
    [yf,xf] = find(Mask(yRange,xRange));
    foreX = [];
    foreY = [];
    
    for j = 1:length(yf)
        foreX = [foreX fVx(yf(j),xf(j))];
        foreY = [foreY fVy(yf(j),xf(j))];
    end
    avgVx = sum(foreX)/length(foreX);
    avgVy = sum(foreY)/length(foreY);
    if isnan(avgVx) || isnan(avgVy)
%         error('The updated window location is NaN. Look into this.');
        continue;
    end
    LocalWindows(i,:) = round(LocalWindows(i,:) + [avgVx avgVy]);  
end

end

