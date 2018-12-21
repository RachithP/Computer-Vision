function ShapeConfidences = initShapeConfidences(LocalWindows, MaskOutline, ColorConfidences, WindowWidth, SigmaMin, A, fcutoff, R)
% INITSHAPECONFIDENCES Initialize shape confidences.  ShapeConfidences is a struct you should define yourself.
% Adaptive Shape confidence values

for i = 1:length(LocalWindows)

    % Defining the values of Sigmas

    if fcutoff < ColorConfidences(i).confidence
        sigmaS = SigmaMin + A*(ColorConfidences(i).confidence-fcutoff)^R;
    else
        sigmaS = SigmaMin;        
    end

    % Defining the window center and its range
    cy = LocalWindows(i,2);
    cx = LocalWindows(i,1);
    yRange = (cy-(WindowWidth/2)):(cy+(WindowWidth/2 - 1));
    xRange = (cx-(WindowWidth/2)):(cx+(WindowWidth/2 - 1));

    % Calculating the distances of each pixel with its nearest non-zero
    % element
    d = bwdist(MaskOutline(yRange,xRange));

    % Shape confidence for each pixel in the 
    ShapeConfidences(i).value = 1 - exp(-(d.^2)/(sigmaS)^2);
%     figure;imshow(ShapeConfidences(i).value)
end