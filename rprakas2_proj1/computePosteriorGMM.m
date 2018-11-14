function [PCx] = computePosteriorGMM(temp,u,sig,pii)

Op = 0.4; % Probability of Orange color - Random initialization

N = 3; % This is constant as we always have RGB component.
PCx=0;
for i=1:size(u,2)
    den = sqrt(((2*pi)^N)*det(sig(:,:,i)));
    invsig = eye(3,3)\(sig(:,:,i));
    PCx = PCx + pii(i)*(Op .*  exp(-0.5*(((temp-u(:,i))')*(invsig)*(temp-u(:,i)))))/den;
end