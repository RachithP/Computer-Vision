function [inlierSource,inlierDest,H_inlier] = applyRANSAC(matchPoint1,matchPoint2)
    %   matchPoint2 is the destination points and matchPoint1 is the source points

    large = 0;                                                              %   Large denoting number of inliers
    
    for j = 1:500
        count = 1;

        ind = randperm(size(matchPoint1,1),4);                              %   choosing 4 random points' indices from the set of features in 2 images
        
        H = est_homography(matchPoint2(ind,1),matchPoint2(ind,2),matchPoint1(ind,1),matchPoint1(ind,2));                %   Estimating Homography based on these 4 random points
        for i = 1:size(matchPoint1,1)
            [x,y] = apply_homography(H,matchPoint1(i,1),matchPoint1(i,2));          %   Calculating the new coordinates after applying the homography and then finding inliers
            s = (matchPoint2(i,1)-x).^2 + (matchPoint2(i,2)-y).^2;                  %   Finding the distance between estimated and the actual location
            if (s<1)                                                               %   Theshold of 10
                inlierSource(count,:) = [matchPoint1(i,1),matchPoint1(i,2)];
                inlierDest(count,:) = [matchPoint2(i,1),matchPoint2(i,2)];
                count = count + 1;
            end
        end
        if (count>large)                                                            %   Min. of 4 points is required to calculate homography matrix
            large = count;
            if (large<4)
               error(message('Not enough inliers to compute Homography')); 
            end
        end
        if (count/size(matchPoint1,1)) >= 0.95                                      %   Break the chain if we obtain 95% of matches as inliers
            disp('Inside break');
            break; 
        end
    end
%     tform = est_homography(inlierDest(:,1),inlierDest(:,2),inlierSource(:,1),inlierSource(:,2));
%     H_inlier = projective2d(tform);
    H_inlier = fitgeotrans(inlierDest,inlierSource,'projective');                   %   Calculating the 
end