function [out] = test_GMM(test_dir,threshold,u,sig,pii)

test_images = dir(test_dir);
    out = zeros(1,1);
    for i=1:length(test_images)
        I = imread([test_images(i).folder '\' test_images(i).name]);
        I = im2double(I);
        Z = I;
        Z = imgaussfilt(Z,5);
        output_Image = zeros(size(Z,1),size(Z,2),3);
        for j=1:size(Z,1)
            for k=1:size(Z,2)
                temp = reshape(Z(j,k,:),[3 1]);
                PCx = computePosteriorGMM(temp,u,sig,pii);
                if PCx > threshold
                    out = [out PCx];
                    output_Image(j,k,:) = I(j,k,:);
                end
            end 
        end
%         figure;
%         imshowpair(I,output_Image,'montage');
%         imwrite(output_Image,[test_images(i).folder '\output_' test_images(i).name]);
    end
end