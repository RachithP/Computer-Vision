function [output] = cannyEdgeDetector(Image, lowerThreshold, upperThreshold)

upperThreshold = 100;
lowerThreshold = 20;
Image = imread('zebra.jpg');

% Read Image
I = rgb2gray(Image);
I = double(I);

% Define a Gaussian filter
G = fspecial('Gaussian',5,1.6);   %   Taken window size as ~6*sigma

% Take the derivative of Image w.r.t Gaussian filter or in other words pass
% the image through a gaussian filter -- Effectively adding Gaussian blur
H = conv2(I,G,'same');

% Sobel filter
fx = -(fspecial('Sobel'))'; 
fy = fx';

% Taking derivatives along x and y direction of the Image
Hx = conv2(H,fx,'same');
Hy = conv2(H,fy,'same');

% Calculating Direction of Gradient
gradDir = computeAngle(Hx,Hy);

% Calculating Magnitude of Gradient
gradMag = sqrt(Hx.^2 + Hy.^2);

% Non-max suppression
[marker,Img] = nonMaximalSupression(gradDir,gradMag,upperThreshold,lowerThreshold);
figure;imshow((Img));title('Non-max');

% Hysterical thresholding
output = hystericalThresholding(marker,gradDir,Img,lowerThreshold);
figure;imshowpair(output,Image,'montage');title('CannyEdgeDetector!');

% % local maxima
% for i = 2:size(output,1)-1
%     for j = 2:size(output,2)-1
%         if max(max(output((i-1:i+1),(j-1:j+1)))) > output(i,j) %   taking a 8 link window
%             output(i,j) = 0;  % Setting values which are not local max to zero
%         end        
%     end
% end
% figure;imshow((output))
end