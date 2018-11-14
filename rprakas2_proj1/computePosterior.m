function [PCx] = computePosterior(temp,u,sig,invsig)

Op = 0.4; % Probability of Orange color - Random initialization

N = 3; % This is a constant as we always have RGB component.
den = 1/sqrt(((2*pi)^N)*det(sig));
% invsig = inv(sig);

PCx = ((1/den) .* Op .*  exp(-0.5*(((temp-u)')*(invsig)*(temp-u))));