function [] = myharris(Image, window_size, corner_threshold)

%   Initializing values which would be taken as input to this function later on
window_size = 5;
Image = imread('1.jpg');
I = rgb2gray(Image);
I = im2double(I)*255;

% Smoothing
I = imgaussfilt(I,1);   %   Smoothing using gaussian.%  This is also equivalent to taking derivative wrt gaussian filter as we are applying gaussian filter here.

% % Defining filters along x and y direction
filtx = [-1 0 1;-1 0 1;-1 0 1];     %   Prewitt filters
filty = [1 1 1;0 0 0;-1 -1 -1];

% filtx = (1/8).*[-1 -2 -1;0 0 0;1 2 1];     %   Sobel filters - good approximation for gaussian filter
% filty = (1/8).*[1 2 1;0 0 0;-1 -2 -1];

Ix = imfilter(I,filtx); %   Gradient along x-direction using filtx for convolving
Iy = imfilter(I,filty); %   Gradient along y-direction using filty for convolving

% Gaussian filter using fspecial
G = fspecial('gaussian',window_size,window_size/6);
SIx2 = imfilter(Ix.^2,G);
SIy2 = imfilter(Iy.^2,G);
SIxy = imfilter(Ix.*Iy,G);

output = zeros(size(Ix,1),size(Ix,2));
R = zeros(size(Ix,1),size(Ix,2));
lamda1 = zeros(1);
lamda2 = zeros(1);

for i = 1:size(Ix,1)
    for j = 1:size(Ix,2)
        M = [SIx2(i,j) SIxy(i,j);SIxy(i,j) SIy2(i,j)];
        D = eig(M);
        lamda1 = [lamda1 D(1)];
        lamda2 = [lamda2 D(2)];
        response = det(M)-0.04*trace(M).^2;
        if response > 100000
            R(i,j) = response;
            output(i,j) = sqrt(Ix(i,j).^2+Iy(i,j).^2);
        end
    end
end

subplot(2,2,1);
imshow(output);title('Before local maxima');

%   Local maxmima algorithm.

for i = 2:size(output,1)-1
    for j = 2:size(output,2)-1
        if max(max(output((i-1:i+1),(j-1:j+1)))) ~= output(i,j) %   taking a 8 link window
            output(i,j) = 0;  % Setting values which are not local max to zero
            R(i,j) = 0;
        end        
    end
end

% subplot(2,2,2);
% imwrite(output,'Image2_heatmap.jpg');
subplot(2,2,3);
imshow(Image)
hold on;
C = corner(I,'Harris');
plot(C(:,1),C(:,2),'*');title('Inbuilt Harris corner detector')
hold off

% Plotting corners
[arr,ind] = sort(output(:),'descend');
[b,a] = ind2sub([size(R,1),size(R,2)],ind);
subplot(2,2,4); imshow(Image); hold on;
for i=1:200
	plot(a(i), b(i), 'b*');title('Plotting corners');
end
hold off

% % Plotting Ix vs Iy and lamdas
% figure;
% subplot(1,2,1);
% plot(Ix2(:),Iy2(:),'.');title('Variation of Ix and Iy');xlabel('Ix ->');ylabel('Iy ->');    %   This shows how Ix and Iy are varying along the Image
% subplot(1,2,2);
% plot(lamda1(:),lamda2(:),'r.');title('Variation of lamda1 and lamda2');xlabel('lamda1 ->');ylabel('lamda2 ->');

end