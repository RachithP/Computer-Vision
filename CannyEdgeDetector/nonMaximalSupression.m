function [marker,mag]=nonMaximalSupression(theta,mag,ht,lt)

% We are taking the gradient direction and magniture matrices as inputs
% and checking the max. magnitude of a pixel along the direction of the edge 
% which is _|_ to direction of the gradient. This is done to find out if
% the direction of gradient is max in that pixel or neighboring pixels.

% We will be loosing the edge pixels information if we start from 2nd
% pixel,so better pad it with zeros all around. Note: We are lookng at a
% 3x3 pixel window, center pixel being the focus of comparison.

mag = padarray(mag,[1,1]);
theta = padarray(theta,[1,1]);
[y,x]=size(theta);
marker = zeros(size(mag));

for i=2:y-1
    for j=2:x-1
        
        if mag(i,j) < lt
            mag(i,j) = 0;
        end
        
        if mag(i,j) < ht
            continue;
        end
        
        flag = 1;
        
        if (theta(i,j)==135)
            if ((mag(i+1,j+1)>mag(i,j))||(mag(i-1,j-1)>mag(i,j)))
                  flag = 0;
            end
        elseif (theta(i,j)==45)   
            if ((mag(i-1,j+1)>mag(i,j))||(mag(i+1,j-1)>mag(i,j)))
                  flag = 0;
            end
        elseif (theta(i,j)==90)   
            if ((mag(i+1,j)>mag(i,j))||(mag(i-1,j)>mag(i,j)))   
                  flag = 0;
            end
        elseif (theta(i,j)==0)   
            if ((mag(i,j+1)>mag(i,j))||(mag(i,j-1)>mag(i,j)))
                  flag = 0;
            end
        end
        if (flag == 1)
            marker(i,j) = 255; 
        end
    end
end
end