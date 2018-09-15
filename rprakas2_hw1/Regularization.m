clear
tic
load('data\data2.mat');
x=pts;clear pts;

% Calculating the co-variance matrix of the data given.
covar = fliplr((((x-mean(x,2))*fliplr((x-mean(x,2))'))/(length(x)-1)));

% Penalizing factor
lamda = [1 0;0 1];

X1 = [x(1,:);ones(1,length(x))];    % Creating a matrix in polynomial form 

% Least square solution B with Regularization 
B = inv(X1(:,:)*(X1(:,:))'+ lamda)*X1(:,:)*(x(2,:))'; % B = inv(X'X + _/\_I)X'Y -> Least square solution

figure;plot(x(1,:),x(2,:),'.');     % Original data
title('Dataset2'); xlabel('X-axis'); ylabel('Y-axis');
hold on
plot(x(1,:),B(1)*x(1,:) + B(2));    % Equation of the best fit line
legend('scatterplot','Best Fit line')
hold off