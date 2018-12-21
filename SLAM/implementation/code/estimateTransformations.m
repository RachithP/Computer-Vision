function [H,R,T]= estimateTransformations(X,x,K)
% INPUT
% 'x' corresponds to image coordinates
% 'X' corresponds to world coordinates
% K is the calibration matrix

% OUTPUT
% H is the Homography matrix
% R, T are the rigid body transformations(Pose) between image frame and world frame


% Solving for Homography. A*h=0;
A = [X(:,1).' 0 0 0 -X(:,1).'*x(1,1);...
     0 0 0 X(:,1).' -X(:,1).'*x(2,1);...
     X(:,2).' 0 0 0 -X(:,2).'*x(1,2);...
     0 0 0 X(:,2).' -X(:,2).'*x(2,2);...
     X(:,3).' 0 0 0 -X(:,3).'*x(1,3);...
     0 0 0 X(:,3).' -X(:,3).'*x(2,3);...
     X(:,4).' 0 0 0 -X(:,4).'*x(1,4);...
     0 0 0 X(:,4).' -X(:,4).'*x(2,4)];
 
[~,~,v] = svd(A.'*A);
val = reshape(v(:,9),3,3)';
H = val/(val(3,3));
valT = inv(K)*H;

% Solving for R, T matrices. Setting H33 = 1. Enforcing 8 DOF.
temp = [valT(:,1) valT(:,2) cross(valT(:,1),valT(:,2))];
[U,~,V] = svd(temp);
R = U*[1 0 0;0 1 0;0 0 det(U*V.')]*V.';
T = valT(:,3)/norm(valT(:,1),2);

end