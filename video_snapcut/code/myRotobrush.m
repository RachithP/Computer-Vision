clear;
clc;
tic;
% Some parameters need to tune:
WindowWidth = 80;  
ProbMaskThreshold = 0.5; 
NumWindows = 40; 
BoundaryWidth = 5;
K = 4;

% Load images:
fpath = '../input/Frames1';
outpath = '../output';
files = dir(fullfile(fpath, '*.jpg'));
imageNames = zeros(length(files),1);
images = cell(length(files),1);

for i=1:length(files)
    imageNames(i) = str2double(strtok(files(i).name,'.jpg'));
end

imageNames = sort(imageNames);
imageNames = num2str(imageNames);
imageNames = strcat(imageNames, '.jpg');

for i=1:length(files)
    images{i} = im2double(imread(fullfile(fpath, strip(imageNames(i,:)))));
end

% NOTE: to save time during development, you should save/load your mask rather than use ROIPoly every time.
% mask = roipoly(images{1});
% save('mask2.mat','mask')
load('../input/mask.mat')
% imshow(imoverlay(images{1}, boundarymask(mask,8),'red'));
% set(gca,'position',[0 0 1 1],'units','normalized')
% F = getframe(gcf);
% [I,~] = frame2im(F);
% imwrite(I, fullfile(strip(imageNames(1,:))));
outputVideo = VideoWriter(fullfile(outpath,'video.mp4'),'MPEG-4');
open(outputVideo);
% writeVideo(outputVideo,I);

% Sample local windows and initialize shape+color models:
[mask_outline, LocalWindows] = initLocalWindows(images{1},mask,NumWindows,WindowWidth,false);

[fc] = initColorModels(images{1},mask,mask_outline,LocalWindows,BoundaryWidth,WindowWidth,K,NumWindows);

% save('ColorConfidence2.mat','fc')
% load ColorConfidence5.mat

% % Show initial local windows and output of the color model:
% imshow(images{1})
% hold on
% showLocalWindows(LocalWindows,WindowWidth,'r.');
% hold off
% % set(gca,'position',[0 0 1 1],'units','normalized')
% % F = getframe(gcf);
% % [I,~] = frame2im(F);

% showColorConfidences(images{1},mask_outline,[fc(:).confidence],LocalWindows,WindowWidth);

% You should set these parameters yourself:
fcutoff = 0.85;
SigmaMin = 2;
SigmaMax = WindowWidth;
R = 2;
A = (SigmaMax-SigmaMin)/((1-fcutoff)^R);

ShapeConfidences = ...
    initShapeConfidences(LocalWindows, mask_outline, fc, WindowWidth, SigmaMin, A, fcutoff, R);

%%% MAIN LOOP %%%
% Process each frame in the video.
% for prev=1:(length(files)-1)
for prev=1:(length(files)-1)
    curr = prev+1;
    fprintf('Current frame: %i\n', curr)
    
    %%% Global affine transform between previous and current frames:
    [warpedFrame, warpedMask, warpedMaskOutline, warpedLocalWindows] = calculateGlobalAffine(images{prev}, images{curr}, mask, LocalWindows);
%     figure;imshow(images{curr})
%     hold on
%     showLocalWindows(warpedLocalWindows,WindowWidth,'r+');
%     showLocalWindows(LocalWindows,WindowWidth,'b.');
%     hold off

    %%% Calculate and apply local warping based on optical flow:
    [NewLocalWindows,flow] = ...
        localFlowWarp(warpedFrame, images{curr}, warpedLocalWindows, warpedMask, WindowWidth);
%     Show windows before and after optical flow-based warp:
%     figure;
%     imshow(images{curr});
%     hold on
%     showLocalWindows(warpedLocalWindows,WindowWidth,'r.');
%     showLocalWindows(NewLocalWindows,WindowWidth,'b.');
%     hold off 
    
    %%% UPDATE SHAPE AND COLOR MODELS:
%     This is where most things happen.
%     Feel free to redefine this as several different functions if you prefer.
    [ ...
        ColorModels, ...
        ShapeConfidences, ...
        mask, ...
        mask_outline, ...
        LocalWindows ...
    ] = ...
    updateModels(...
        NewLocalWindows, ...
        images{curr}, ...
        warpedMask, ...
        warpedMaskOutline, ...
        WindowWidth, ...
        fc, ...
        ShapeConfidences, ...
        ProbMaskThreshold, ...
        fcutoff, ...
        SigmaMin, ...
        R, ...
        A, ...
        K ...
    );

% %     % Write video frame:
%     imshow(imoverlay(images{curr}, boundarymask(mask,8), 'red'));
% %     set(gca,'position',[0 0 1 1],'units','normalized')
    F = getframe(gcf);
%     [I,~] = frame2im(F);
%     imwrite(I, fullfile(outpath,strip(imageNames(curr,:))));
    writeVideo(outputVideo,F);

%     imshow(images{curr})
%     hold on
%     showLocalWindows(NewLocalWindows,WindowWidth,'r.');
%     hold off
%     set(gca,'position',[0 0 1 1],'units','normalized')
%     F = getframe(gcf);
%     [I,~] = frame2im(F);
end

close(outputVideo);
toc