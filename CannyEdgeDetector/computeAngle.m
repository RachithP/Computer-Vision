function [t] = computeAngle(Ix,Iy)

% Calculating gradient at each pixel
theta = atan2(Iy,Ix);

% Converting from radians to degrees
theta=theta*180/pi;

[y,x] = size(theta);

% Calculating direction of gradient for each pixel i.e. bundling the pixels
% into 1 of the 4 possible angles. These angles are based on the 4 possbile
% directions of edges possible around a pixel.

for i=1:y
    for j=1:x
        if(theta(i,j)<0)
            theta(i,j)= theta(i,j) + 360;
        end     
    end
end

t = zeros(size(theta));

for i=1:y
    for j=1:x      
        if ((theta(i, j) >= 0 ) && (theta(i, j) < 22.5) || (theta(i, j) >= 157.5) && (theta(i, j) < 202.5) || (theta(i, j) >= 337.5) && (theta(i, j) <= 360))
            t(i, j) = 0;
        elseif ((theta(i, j) >= 22.5) && (theta(i, j) < 67.5) || (theta(i, j) >= 202.5) && (theta(i, j) < 247.5))
            t(i, j) = 45;
        elseif ((theta(i, j) >= 67.5 && theta(i, j) < 112.5) || (theta(i, j) >= 247.5 && theta(i, j) < 292.5))
            t(i, j) = 90;
        elseif ((theta(i, j) >= 112.5 && theta(i, j) < 157.5) || (theta(i, j) >= 292.5 && theta(i, j) < 337.5))
            t(i, j) = 135;
        end
   end
end

end
