function [marker] = hystericalThresholding(marker,theta,mag,lt)

% marker is the processed image going through nonmaxsup
% theta is the matrix with angles assigned to each pixel
% lt is the lower threshold.

alter = 1;

marker = padarray(marker,[3,3]);
mag = padarray(mag,[3,3]);
theta = padarray(theta,[3,3]);
[y,x] = size(theta);
iter = 1;

while alter
    alter = 0;
    iter = iter + 1;
    for i = 4:y-3
        for j = 4:x-3

            if (marker(i,j) == 255)
                
                marker(i,j) = 10;

                if (theta(i,j)==135)
                    if ((mag(i-1,j-1)>lt) && (marker(i-1,j-1)~=10) && (theta(i-1,j-1)==135) && (mag(i-1,j-1)>mag(i-2,j)) && (mag(i-1,j-1)>mag(i,j-2)))
                        marker(i-1,j-1) = 255;                    
                        alter = 1;
                    end   
                    if ((mag(i+1,j+1)>lt) && (marker(i+1,j+1)~=10) && (theta(i+1,j+1)==135) && (mag(i+1,j+1)>mag(i+2,j)) && (mag(i+1,j+1)>mag(i,j+2)))
                        marker(i+1,j+1) = 255;                    
                        alter = 1;
                    end
                elseif (theta(i,j)==45)   
                    if ((mag(i-1,j+1)>lt) && (marker(i-1,j+1)~=10) && (theta(i-1,j+1)==45) && (mag(i-1,j+1)>mag(i-2,j)) && (mag(i-1,j+1)>mag(i,j+2)))
                        marker(i-1,j+1) = 255;                    
                        alter = 1;
                    end   
                    if ((mag(i+1,j-1)>lt) && (marker(i+1,j-1)~=10) && (theta(i+1,j-1)==45) && (mag(i+1,j-1)>mag(i+2,j)) && (mag(i+1,j-1)>mag(i,j-2)))
                        marker(i+1,j-1) = 255;                    
                        alter = 1;
                    end
                elseif (theta(i,j)==90)   
                    if ((mag(i,j-1)>lt) && (marker(i,j-1)~=10) && (theta(i,j-1)==90) && (mag(i,j-1)>mag(i-1,j-1)) && (mag(i,j-1)>mag(i+1,j-1)))
                        marker(i,j-1) = 255;                    
                        alter = 1;
                    end   
                    if ((mag(i,j+1)>lt) && (marker(i,j+1)~=10) && (theta(i,j+1)==90) && (mag(i,j+1)>mag(i-1,j+1)) && (mag(i,j+1)>mag(i+1,j+1)))
                        marker(i,j+1) = 255;                    
                        alter = 1;
                    end
                elseif (theta(i,j)==0)   
                    if ((mag(i-1,j)>lt) && (marker(i-1,j)~=10) && (theta(i-1,j)==0) && (mag(i-1,j)>mag(i-1,j-1)) && (mag(i-1,j)>mag(i-1,j+1)))
                        marker(i-1,j) = 255;                    
                        alter = 1;
                     end
                    if ((mag(i+1,j)>lt) && (marker(i+1,j)~=10) && (theta(i+1,j)==0) && (mag(i+1,j)>mag(i+1,j-1)) && (mag(i+1,j)>mag(i+1,j+1)))
                        marker(i+1,j) = 255;                    
                        alter = 1;
                    end
                end                
            end
        end
    end
end

for i = 2:y-1
    for j = 2:x-1
        if marker(i,j) == 10
            marker(i,j) = 255;
        end
    end
end

end