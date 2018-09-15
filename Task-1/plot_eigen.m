clear
tic
covar=zeros(2,1);
X=zeros(2,1);
% Looping through the 3 datasets.
for j=1:3
    load(['data\data' num2str(j) '.mat']);
    X = [X pts];
    x=pts;clear pts;
    % Calculating the co-variance matrix of the data given.
    covar = [covar fliplr((((x-mean(x,2))*fliplr((x-mean(x,2))'))/(length(x)-1)))];
end

% Segregating values obtained in previous calculation
X1 = X(:,2:length(x)+1);
X2 = X(:,length(x)+2:2*length(x)+1);
X3 = X(:,2*length(x)+2:3*length(x)+1);
covar1 = covar(:,2:3);
covar2 = covar(:,4:5);
covar3 = covar(:,6:7);

% Finding the eigen vectors and eigen values of the above co-variance matrices using inbuilt functions
[V1,D1] = eig(covar1);
[V2,D2] = eig(covar2);
[V3,D3] = eig(covar3);

% parametrization
t=0:0.01:2*pi;

% Rotation matrix is given by R = [cosw -sinw;sinw cosw]. 
% Finding the angle of rotation by finding the slope of the major axis wrt x-axis
w1 = atan((V1(2,2)-0)/(V1(1,2)-0));

% Multiply [acos(t); bsin(t)] by R. Taking confidence parameter as 1
x1 = 2*((sqrt(D1(4)))*cos(t)*cos(w1) - (sqrt(D1(1)))*sin(t)*sin(w1));
y1 = 2*((sqrt(D1(1)))*sin(t)*cos(w1) + (sqrt(D1(4)))*cos(t)*sin(w1));
figure;plot(X1(1,:),X1(2,:),'.');
title('Dataset1')
xlabel('X-axis')
ylabel('Y-axis')
hold on
plot(x1,y1,'r');
plot(sqrt(D1(1))*[0,V1(1,1)],sqrt(D1(1))*[0,V1(2,1)],'Color',[0.9 0.9 0]);
plot(sqrt(D1(4))*[0,V1(1,2)],sqrt(D1(4))*[0,V1(2,2)],'g');
legend('scatterplot','Error Ellipse with more confidence','Error Ellipse','Eigen vector along minor axis','Eigen vector along major axis')
hold off

% Finding the angle of rotation by finding the slope of the major axis wrt x-axis
w2 = atan2(V2(2,2),V2(1,2));
x2 = 2*((sqrt(D2(4)))*cos(t)*cos(w2) - (sqrt(D2(1)))*sin(t)*sin(w2));
y2 = 2*((sqrt(D2(1)))*sin(t)*cos(w2) + (sqrt(D2(4)))*cos(t)*sin(w2));
figure;plot(X2(1,:),X2(2,:),'.');
title('Dataset2')
xlabel('X-axis')
ylabel('Y-axis')
hold on
plot(x2,y2);
plot(sqrt(D2(1))*[0,V2(1,1)],sqrt(D2(1))*[0,V2(2,1)],'Color',[0.9 0.9 0]);
plot(sqrt(D2(4))*[0,V2(1,2)],sqrt(D2(4))*[0,V2(2,2)],'g');
legend('scatterplot','Error Ellipse','Eigen vector along minor axis','Eigen vector along major axis')
hold off

% Finding the angle of rotation by finding the slope of the major axis wrt x-axis
w3 = atan2(V3(2,2),V3(1,2));
x3 = 2*((sqrt(D3(4)))*cos(t)*cos(w3) - (sqrt(D3(1)))*sin(t)*sin(w3));
y3 = 2*((sqrt(D3(1)))*sin(t)*cos(w3) + (sqrt(D3(4)))*cos(t)*sin(w3));
figure;plot(X3(1,:),X3(2,:),'.');
title('Dataset3')
xlabel('X-axis')
ylabel('Y-axis')
hold on
plot(x3,y3);
plot(sqrt(D3(1))*[0,V3(1,1)],sqrt(D3(1))*[0,V3(2,1)],'Color',[0.9 0.9 0]);
plot(sqrt(D3(4))*[0,V3(1,2)],sqrt(D3(4))*[0,V3(2,2)],'g');
legend('scatterplot','Error Ellipse','Eigen vector along minor axis','Eigen vector along major axis')
hold off

toc