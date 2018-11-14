function [a] = computeDistance(image,poly)

    Z = im2double(imread(image));
    I = rgb2gray(Z);
    
%     Converting to logical values.
    BW = I > 0.4;
    
%     Calculating the region of interest and estimating its area and find its distance from camera.
    bw = bwmorph(BW,'clean');
    s = regionprops(bw,I,'Area','Centroid','Perimeter');
    numObj = numel(s);

    % Getting the area of region of interst by assuming it is having the most pixel density.

    a = s(1).Area;      % Area of the region of interst
    index = 1;          % Its place in the struct variable
    for k = 2 : numObj
        b = s(k).Area;
        if (b>=a)
            a=b;
            index = k;
        end
    end
    
    % Calculating the radius of the circle obtained. Assuming it's a circle by  default.
    p = s(index).Perimeter;
    rad = 2*a/p;
    
    % Diplaying the ball and its center.
    t = 0:0.01:2*pi;
    x = s(index).Centroid(1) + rad*cos(t);
    y = s(index).Centroid(2) + rad*sin(t);

    dist = polyval(poly,a);
    position = [5 50];
    figure;
%     mat2gray(bw)
    imshow(insertText(Z,position,strcat('distance = ', num2str(dist),' cm'),'Font','Cambria','BoxColor','y','TextColor','white'));
%     figure;
%     imshow(bw);
    hold on
%     plot(x,y,'g');
    plot(s(index).Centroid(1), s(index).Centroid(2), 'bo');
    title('Object is identified by blue circle, i.e its centroid');
    hold off
end
