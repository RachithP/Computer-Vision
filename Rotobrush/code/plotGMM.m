function [] = plotGMM(u,sig)
    % here for u, we are taking each row corresponds to an ellipsoid
    % Each col will be R,G,B
    % Thus each eigvector obtained from sig , will be the basis for
    % ellipsoid and thus we are rotating each x,y,z by the eigenvector
    % matrix whic is the tranformation matrix
    N = 40;
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
                X(j,k) = P(1)+u(i,1);
                Y(j,k) = P(2)+u(i,2);
                Z(j,k) = P(3)+u(i,3);
            end
        end
        mesh(X,Y,Z);
        axis equal
        hidden off
        hold on
    end
end