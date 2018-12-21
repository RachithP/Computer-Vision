function [fc, ShapeConfidences,mask,mask_outline,NewLocalWindows] = ...
    updateModels(...
        NewLocalWindows, ...
        CurrentFrame, ...
        mask, ...
        mask_outline, ...
        WindowWidth, ...
        fc, ...
        ShapeConfidences, ...
        ProbMaskThreshold, ...
        fcutoff, ...
        SigmaMin, ...
        R, ...
        A, ...
        K ...
    ) 
% UPDATEMODELS: update shape and color models, and apply the result to generate a new mask

% Getting a tempshape confidence value based on previous color model to calculate new shape confidence values
% This will happen once for each frame

for p = 1:1 % This 'for' loop is used for iterative refinement.

    tempShapeConfidences = ...
        initShapeConfidences(NewLocalWindows, mask_outline, fc, WindowWidth, SigmaMin, A, fcutoff, R);
    % Define variables
    temp.numerator = zeros(size(mask));
    temp.denominator = zeros(size(mask));
    pF = zeros(size(mask));
    
    for i = 1:length(NewLocalWindows)
 
        % Defining the window center and its range
        cy = NewLocalWindows(i,2);
        cx = NewLocalWindows(i,1);
        yRange = (cy-(WindowWidth/2)):(cy+(WindowWidth/2 - 1));
        xRange = (cx-(WindowWidth/2)):(cx+(WindowWidth/2 - 1));    

        % Distance matrix used for shape and color confidence calculation
        d = bwdist(mask_outline(yRange,xRange));

        %% Updating Color Model

        % Converting to L.A.B color space   
        IMG = rgb2lab(CurrentFrame(yRange,xRange,:));    % IMG also is taken for that particular window range
        localMask = mask(yRange,xRange);
%         [yf,xf] = find(localMask);
        [yb,xb] = find(~localMask);

%         foreGroundData = [];
        backGroundData = [];

%         for j = 1:length(yf)
%             foreGroundData = [foreGroundData [IMG(yf(j),xf(j),1);IMG(yf(j),xf(j),2);IMG(yf(j),xf(j),3)]];
%         end

        for j = 1:length(yb)
            if tempShapeConfidences(i).value(yb(j),xb(j)) < 0.25
                backGroundData = [backGroundData [IMG(yb(j),xb(j),1);IMG(yb(j),xb(j),2);IMG(yb(j),xb(j),3)]];
            end
        end

%         if size(foreGroundData,1)>3
%             foreGMModel = fitgmdist(foreGroundData',K,'RegularizationValue',0.001);        
%         else
            foreGMModel = fc(i).foreGMM;
%         end

        if size(backGroundData,1)>3
            backGMModel = fitgmdist(backGroundData',K,'RegularizationValue',0.001);   
        else
            backGMModel = fc(i).backGMM;
        end

        datafit = reshape(IMG,WindowWidth^2,3);

        % Calculating probability mask based on old model of fc.foreGMM and new fc.backGMM
        pxFh = pdf(fc(i).foreGMM,datafit);
        pxBh = pdf(fc(i).backGMM,datafit);
        valb = pxFh./(pxFh+pxBh);
        pCXhistory = reshape(valb,WindowWidth,WindowWidth);

        % Calculating probability mask based on new updated model foreGMModel and backGMModel
        pxFn = pdf(foreGMModel,datafit);
        pxBn = pdf(backGMModel,datafit);
        valn = pxFn./(pxFn+pxBn);   
        pCXnew = reshape(valn,WindowWidth,WindowWidth);

%         imshowpair(pCXnew,pCXhistory,'montage');
%         imshowpair(pCXhistory,img,'montage');

        [new,~] = find(pCXnew>0.8);
        [history,~] = find(pCXhistory>0.8);

        % Since we are taking foreground model to be constant across frames
        % we can consider the below condition as : if the background data
        % changes a lot, then the number of pixels classified as foreground
        % would be less, hence we update the background model with the new
        % model.
        if (length(new)<length(history))
            weight = exp(-(d.^2)/(WindowWidth*0.5)^2);
            den = sum(sum(weight));
            val = sum(sum(abs(localMask - pCXnew).*weight));

            fc(i).confidence = 1 - val/den;
%             fc(i).foreGMM = foreGMModel;
            fc(i).backGMM = backGMModel;
            pCX = pCXnew;
        else
            pCX  = pCXhistory;
        end

        %% Updating Shape Model
        % Calculating the new shape confidence based on the sigmaS calculated Shape confidence for each pixel in the window 

        if fcutoff < fc(i).confidence
            sigmaS = SigmaMin + A*(fc(i).confidence-fcutoff)^R;
        else
            sigmaS = SigmaMin;        
        end

        ShapeConfidences(i).value = 1 - exp(-(d.^2)/((sigmaS)^2));

        %% Merging color and shape confidence values for each window
        pFx = ShapeConfidences(i).value.*localMask+(1-ShapeConfidences(i).value).*pCX;
%         imshowpair(pFx,pCX,'montage');

        %% Merging windows
        % Calculating the final foreground probability for all pixels in the image
        for k = 1:length(yRange)
            for h = 1:length(xRange)
                distFromCenter = 1/(sqrt((yRange(k)-cy)^2 + (xRange(h)-cx)^2)+0.1);
                [~,yloc] = ismember(yRange(k),yRange);
                [~,xloc] = ismember(xRange(h),xRange);
                temp.numerator(yRange(k),xRange(h)) = temp.numerator(yRange(k),xRange(h)) + pFx(yloc,xloc)*distFromCenter;
                temp.denominator(yRange(k),xRange(h)) = temp.denominator(yRange(k),xRange(h))+ distFromCenter;
            end
        end              
    end 

    % Obtaining the final foreground probability mask
    pF = (temp.numerator)./(temp.denominator);

    % Removing NaN values resulting from previous division
    pF(isnan(pF))=0;
    mask = (pF>0.85);
    imshow(imoverlay(CurrentFrame, boundarymask(mask,8), 'red'));
    set(gcf,'visible','off')

    % Getting mask outline from the new mask generated above
    mask_outline = bwperim(mask,4);
end

%% Lazysnapping implementation
% % Get the positions of background and foreground from the above probability
% % mask
% [frow,fcol] = find(pF);
% foreInd = sub2ind(size(pF),frow,fcol);
% 
% [brow,bcol] = find(~pF);
% backInd = sub2ind(size(pF),brow,bcol);
% 
% % Extracting the final foreground mask using lazysnapping
% L = superpixels(CurrentFrame,max(length(frow),length(brow)));
% BW = lazysnapping(CurrentFrame,L,foreInd,backInd,'EdgeWeightScaleFactor',300);
% maskedImage = CurrentFrame;
% maskedImage(repmat(~BW,[1 1 3])) = 0;
% imshow(maskedImage);title('MaskedImage')
% mask = maskedImage;
% imshow(imoverlay(CurrentFrame, boundarymask(mask,8), 'red'));