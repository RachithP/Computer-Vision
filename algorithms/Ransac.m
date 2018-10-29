% Implementation of RANSAC algorithm for lien fitting
clear
tic

% Loading data which has (x,y), x as it's rows and y as its columns.
load('data\data2.mat');
x=pts;clear pts;

% Calculating the co-variance matrix of the data given.
covar = fliplr((((x-mean(x,2))*fliplr((x-mean(x,2))'))/(length(x)-1)));

% Ransac algorithm
% Iterate N times -> choosing N sets of 2 random points

% Setting threshold parameters
delta = 6; % min distance from any point to the line
epsolon = 100; % min number of points of the dataset that are within delta required exit the loop

for i=1:200
    a = randi([1, 200]);
    b = randi([1, 200]);
    Y = zeros(2,1);

% X = [x1 x2;y1 y2]
    X = [x(1,a) x(1,b);x(2,a) x(2,b)];
    
% Perpendicular distance from any other point to the line formed by points in X is d.
% Iterating through all the points in the dataset to reject outliers (d>delta).   
    for j = 1:200
        point = [x(1,j);x(2,j)];
        d = abs((x(2,b)-x(2,a))*point(1) - (x(1,b)-x(1,a))*point(2) + det(fliplr(X)))/sqrt((x(2,b)-x(2,a))^2 + (x(1,b)-x(1,a))^2);
        if (d <= delta)
            Y = [Y point];
        end
    end
    Y = Y(:,2:length(Y)-1);
    if length(Y) >= epsolon
        X1 = [Y(1,:);ones(1,length(Y))];    % Creating a matrix in polynomial form 
        B = inv(X1(:,:)*(X1(:,:))')*X1(:,:)*(Y(2,:))'; % B = inv(X'X)X'Y -> Least square solution
        figure;plot(x(1,:),x(2,:),'.');     % Original data
        title('Dataset2'); xlabel('X-axis'); ylabel('Y-axis');
        hold on
        scatter(Y(1,:),Y(2,:),'g');     % Plotting inliers
        plot(Y(1,:),B(1)*Y(1,:) + B(2),'r');    % Equation of the line fitting inliers
        legend('scatterplot of original data','Inliers','Best fit line');
        hold off
        break
    end
end
toc
