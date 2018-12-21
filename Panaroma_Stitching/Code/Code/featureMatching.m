function [matchPointImg1,matchPointImg2] = featureMatching(feature1,feature2,posy1,posx1,posy2,posx2)
    %   matchPointImg2 is the destination Image and matchPointImg1 is the source image
    %   feature2 is that of the destination and feature 1 is that of the source image
    
    count = 1;
    for i = 1:size(feature1,1)
        s = zeros(1,size(feature2,1));
        for j = 1:size(feature2,1)
            s(j) = sum(sum((feature1(i,:)-feature2(j,:)).^2));              %   Sum of square diff between features to get the best match!
        end
        [val,ind] = sort(s(:),'ascend');                                    %   Sorting to get best one and best two.
        ratio = val(1)/val(2);                                              %   Consider it as a match if there is significant difference in best one and best two.
        if ratio < 0.3
            matchPointImg1(count,:) = [posx1(i),posy1(i)];                  %   Making it [x,y] as showMatchedFeatures accepts this format
            matchPointImg2(count,:) = [posx2(ind(1)),posy2(ind(1))];        %   Making it [x,y] as showMatchedFeatures accepts this format
            count = count + 1;
        end
    end
    
    if count == 1
       error(message('No Matched pair. Please check your input'));          %   Error when there are no matched points. 
    end
end