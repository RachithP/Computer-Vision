function [] = plotGMM(u,sig)

    % u is taken in as each col should correspond to an ellipsoid
    % axes value thus, each row will be r,g,b value
    % each col corresoponds to number of RGB
    N = 30;
    for i=1:size(u,1)
        [V,D] = eig(sig(:,:,i));
        if (eig(sig(:,:,i)) <=0)
            error('The covariance matrix must be positive definite (it should have only positive eigenvalues)')
        end 
        [x,y,z] = ellipsoid(0,0,0,2*sqrt(D(1,1)),2*sqrt(D(2,2)),2*sqrt(D(3,3)),N);
        X = zeros(N+1,N+1);
        Y = zeros(N+1,N+1);
        Z = zeros(N+1,N+1);
        len = length(x);
        for j = 1 : len
            for k = 1 : len
                P = V * [x(j,k);y(j,k);z(j,k)];
                X(j,k) = P(1)+u(1,i);
                Y(j,k) = P(2)+u(2,i);
                Z(j,k) = P(3)+u(3,i);
            end
        end
        mesh(X,Y,Z);
        axis equal
        hidden off
        hold on
    end
end