  function [] = MyPanorama()

clear;clc;
Nbest = 450;                                            %   Initialize values. Nbest = Number of best corners user wants to select.

input_images = dir('../input/*.jpg');                   %   load images from ../Input/ with an extension .jpg
numImages = length(input_images);                       %   Number of images considered in this run.
ind = ceil(numImages/2);                                %   Getting the center Image's indices from the given set of Images
H(numImages) = projective2d(eye(3));                    %   Defining a projective2D matrix for transformations between Images
imageSize = zeros(numImages,2);

for i = 1:numImages
    
    I_read = imread([input_images(i).folder '\' input_images(i).name]);     %   Read image one by one
	I_grey = im2double(rgb2gray(I_read));
    imageSize(i,:) = size(I_grey);
    corners = detectHarrisFeatures(I_grey,'MinQuality',0.000001);           % Get corners using detectHarrisFeatures function
    
    b = nan;
    a = nan;
    Cimg = zeros;                                                           % Cimg = Corner response Image.
    for j = 1:length(corners.Metric)                                        % Calculate corner_response_image from corners detected by detectHarrisFeatures
         if round(corners.Location(j,1)) ~= 0
            a(j) = round(corners.Location(j,1));
        end
        if round(corners.Location(j,1)) ~= 0
            b(j) = round(corners.Location(j,2));
        end
        Cimg(b(j),a(j)) = corners.Metric(j); 
    end
    
    [y(i,:),x(i,:),ANMS_Image] = ANMS(Cimg, Nbest);                         % Input the corner response image to ANMS algorithm to obtain a spread out corner response
    
    features(:,:,i) = featureDescriptor(y(i,:),x(i,:),Cimg);                % Feature Descriptor.                                                                     
%     figure;
%     imshowpair(Cimg>0,ANMS_Image>0,'montage'); 

    %   FEATURE MATCHING , RANSAC ALGORITHM
    if i>1
        [matchPoint1,matchPoint2] = featureMatching(features(:,:,i-1),features(:,:,i),y(i-1,:),x(i-1,:),y(i,:),x(i,:));
%         figure;
%         showMatchedFeatures(imread(['../Images/input/' num2str(i-1) '.jpg']),imread(['../Images/input/' num2str(i) '.jpg']),matchPoint1,matchPoint2,'montage');
%         figure;
        [ransacImage1,ransacImage2,H(i)] = applyRANSAC(matchPoint1,matchPoint2);     
%         showMatchedFeatures(imread(['../Images/input/' num2str(i-1) '.jpg']),imread(['../Images/input/' num2str(i) '.jpg']),ransacImage1,ransacImage2,'montage');
        H(i).T = H(i).T * H(i-1).T;     % %     y -> y-coordinate or rows of the corner obtained from ANMS%   Calculating Transformation matrices of all images w.r.t to 1st image.
    end
end

    %   CALCULATE H -> Homography Matrix of all images wrt to center
    Hinv = invert(H(ind));          %   ind is the center image by assumption. So, we are calculating inverse of the center's Homograpy
                                    %   matrix w.r.t to first image.
    
    for i = 1:numel(H)              %   Obtaining Homography matrix of all images w.r.t center image. This is done to stitch all Images wrt center Image.
        H(i).T = H(i).T * Hinv.T;   
    end
        
    for i = 1:numel(H)              %   Calculating the outputLimits i.e. the x axis limit and y axis limit of the all the homography transformations
        [xlim(i,:), ylim(i,:)] = outputLimits(H(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end

    maxImageSize = max(imageSize);
    
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);                         
                                                                                % Find the minimum and maximum output limits.
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);

    width  = round(xMax - xMin);                                                % Width and height of panorama.
    height = round(yMax - yMin);

    panorama = zeros([height width 3], 'like', imread([input_images(1).folder '\' input_images(1).name]));      % Initialize an "empty" panorama.
    
    blender = vision.AlphaBlender('Operation', 'Binary mask','MaskSource', 'Input port');       %   Inbuilt blender used for blending
    
    xLimits = [xMin xMax];  
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);                   %   Create a 2-D spatial reference object defining the size of the panorama.
    
%      Create the PANORAMA.
    for i = 1:numImages

        I = imread([input_images(i).folder '\' input_images(i).name]);           

        warpedImage = imwarp(I, H(i), 'OutputView', panoramaView);              %   Transform I into the panorama.

        mask = imwarp(true(size(I,1),size(I,2)), H(i), 'OutputView', panoramaView);               % Generate a binary mask.

        panorama = step(blender, panorama, warpedImage, mask);                % Overlay the warpedImage onto the panorama.
    end

    figure
    imshow(panorama);