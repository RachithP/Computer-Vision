function [features] = featureDescriptor(y,x,Img)
% Describing the features of an image with a 1x64 vector
% % Input
% %     y->rows of Img where we have corners
% %     x->rows of Img where we have corners
% % Output
% %     features obtained for these corner point.

    G = fspecial('gaussian',5,1);                                   %   Gaussian blur
    
    img_pad = padarray(Img,[20,20]);                                %   Padd Img to later accomodate a 40x40 window around corner points

    x = x + 20;                                                     %   updating the coordinates according to padding done above
    y = y + 20;                                                        

    count = 1;
    for i = 1:length(x)
        sample = img_pad(y(i)-20:y(i)+20,x(i)-20:x(i)+20);          %   Choosing a 40x40 window around key point
        img_blur = imfilter(sample,G);                              %   Apply gaussian blur
        h = imresize(img_blur,0.18,'bilinear');                       %   sub-sampling to reduce 41x41 to 8x8
        h = reshape(h,[1,64]);                                      %   Creating a 64 row/col feature vector
        features(count,:) = (h - mean(h))/std(h);                   %   Normalizing the feature vector to zero mean and 1 std
        count = count + 1;
    end
end