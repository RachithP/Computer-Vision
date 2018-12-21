% Least square solution to line fitting.
clear
tic
load('data\data2.mat');
x=pts;clear pts;

X1 = [x(1,:);ones(1,length(x))];    % Creating a matrix in polynomial form

% Least square solution B
B = inv(X1(:,:)*(X1(:,:))')*X1(:,:)*(x(2,:))'; % B = inv(X'X)X'Y -> Least square solution

figure;plot(x(1,:),x(2,:),'.');     % Original data
title('Dataset'); xlabel('X-axis'); ylabel('Y-axis');
hold on
plot(x(1,:),B(1)*x(1,:) + B(2));    % Equation of the best fit line
legend('scatterplot','Best Fit line')
hold off