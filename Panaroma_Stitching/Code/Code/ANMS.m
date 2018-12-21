%   Function implementing ANMS algorithm
function [y,x,ANMS_Image] = ANMS(Cimg, Nbest) %   Img is the input corner image
% % Input 
% %     Cimg is a cornerimage response obtained from either cornermetrix or detectHarrisFeatures function
% %     Nbest value is the Number of corner points we would want from ANMS ago.
% % Output
% %     y -> y-coordinate or rows of the corner obtained from ANMS
% %     x -> x-coordinate or rows of the corner obtained from ANMS
% %     ANMS_Image -> output Image

    bimage = imregionalmax(Cimg); %   Considering a local maxima with 8 connected neighbours
    [a,b] = find(bimage);   %   Find coordinates of pixels that are non-zero/corners after local regional maxima
    r = inf([1 numel(a)]);
    ED = 0;
    if Nbest > numel(a)
        error(message('Entered Nbest value is greater than the number of corners found in the Image. Please change the value.'));
    end
    for i = 1:numel(a)
        for j = 1:numel(a)
            if (Cimg(a(j),b(j))>Cimg(a(i),b(i)))
                ED = (a(j)-a(i))^2 + (b(j)-b(i))^2;
            end
            if ED < r(i)
                r(i) = ED;
            end
        end
    end
    
    x = zeros([1 Nbest]);
    y = zeros([1 Nbest]);
%     ANMS_Image = zeros(size(Cimg,1),size(Cimg,2));
    [~,ind] = sort(r(:),'descend');
    for i = 1:Nbest
        y(i) = a(ind(i));   %   row
        x(i) = b(ind(i));   %   col
        ANMS_Image(y(i),x(i)) = Cimg(y(i),x(i));
    end
end