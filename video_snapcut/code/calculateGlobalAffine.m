function [WarpedFrame, WarpedMask, WarpedMaskOutline, WarpedLocalWindows] = calculateGlobalAffine(IMG1,IMG2,Mask,LocalWindows)
% CALCULATEGLOBALAFFINE: finds affine transform between two frames, and applies it to frame1, the mask, and local windows.

% Extract sift features from Image1 and use it to find the affine
% transformation matrix between image1 and Image2. Then, use this
% affine_matrix to transform image1 and get image1'=WarpedFrame. The same
% is applied to Mask, Maskoutline, localWindows to get respective warped
% Images

% NOTE: Take SIFT features of only the foreground area in Image1.

greyIMG1 = (rgb2gray(IMG1));
greyIMG2 = (rgb2gray(IMG2));
% tempIMG1 = zeros(size(greyIMG1));

% [yf,xf] = find(Mask);
% for j = 1:length(yf)
%     tempIMG1(yf(j),xf(j))=greyIMG1(yf(j),xf(j));
% end

points1 = detectSURFFeatures(greyIMG1,'MetricThreshold',300);
points2 = detectSURFFeatures(greyIMG2,'MetricThreshold',300);

[features1,validPoints1] = extractFeatures(greyIMG1,points1);
[features2,validPoints2] = extractFeatures(greyIMG2,points2);

indexPairs = matchFeatures(features1,features2);

matchedPoints1 = validPoints1(indexPairs(:,1),:);
matchedPoints2 = validPoints2(indexPairs(:,2),:);

% Calculate affine transform
afftrans = estimateGeometricTransform(matchedPoints2,matchedPoints1,'affine');

% figure; showMatchedFeatures(greyIMG1,greyIMG2,matchedPoints1,matchedPoints2);

outputView = imref2d(size(IMG2));
WarpedFrame = imwarp(IMG1, invert(afftrans),'OutputView',outputView);

WarpedMask = imwarp(Mask, invert(afftrans),'OutputView',outputView);
WarpedMaskOutline = bwperim(WarpedMask,4);
WarpedLocalWindows = round(transformPointsForward(invert(afftrans),LocalWindows));

% imshowpair(WarpedMask,IMG2,'montage')

%% Show matches if vl_sift
% figure
% subplot(2,1,1)
% imshow(greyIMG1)
% hold on
% plot(X1,Y1,'r+')
% hold off
% subplot(2,1,2)
% imshow(greyIMG2)
% hold on
% plot(X2,Y2,'b+')
% hold off
end
%% Another way to estimate the points needed for correspondence. This is based on nearest points to foreground

% [yo,xo] = find(mask_outline);   % Extracting the coordinates of mask_outline points
% X1 = [];Y1 = [];X2 = [];Y2 = [];
% for j = 1:length(matches)
%     % Extracting the pixel coordinates of the matching features/pixels in
%     % each Image
%     
%     x1 = round(fa(1,matches(1,j)));  % X-components of Img1
%     y1 = round(fa(2,matches(1,j)));  % Y-components of Img1
% 
%     x2 = round(fb(1,matches(2,j)));  % X-components of Img2
%     y2 = round(fb(2,matches(2,j)));  % Y-components of Img2
%         
%     distances = sqrt((xo-x1).^2+(yo-y1).^2);
%     if min(distances) < 15  % Taking min distance of a point from boundary as 15
%         X1 = [X1 x1];   % Points which are expected to be within foreground are stacked for calculating correspondence later on
%         Y1 = [Y1 y1];
%         X2 = [X2 x2];
%         Y2 = [Y2 y2];
%     end
% end

%% Matching features using vl_sift

% % % Creating a new Image with only foreground information of IMG1 in it.
% [yf,xf] = find(Mask);
% for j = 1:length(yf)
%     tempIMG1(yf(j),xf(j))=greyIMG1(yf(j),xf(j));
% end
% 
% [fa, da] = vl_sift(single(tempIMG1)) ;  % Using this image as our first Image. This is done to match features only in foreground.
% [fb, db] = vl_sift(single(greyIMG2)) ;
% [matches, ~] = vl_ubcmatch(da, db, 2) ;
% 
% for j = 1:length(matches)
%     % Extracting the pixel coordinates of the matching features/pixels in
%     % each Image
%     
%     X1(j) = round(fa(1,matches(1,j)));  % X-components of Img1
%     Y1(j) = round(fa(2,matches(1,j)));  % Y-components of Img1
% 
%     X2(j) = round(fb(1,matches(2,j)));  % X-components of Img2
%     Y2(j) = round(fb(2,matches(2,j)));  % Y-components of Img2      
% end
% 
% afftrans = estimateGeometricTransform([X2.',Y2.'],[X1.',Y1.'],'affine');
