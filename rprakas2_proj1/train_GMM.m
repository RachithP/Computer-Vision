function [u,sig,pii,Y,poly] = train_GMM(train_dir,K,Y)

%   Initializing few values
%   train_dir='train_images\*.jpg';
%   K = 5;

    max_iterations = 10; % Max number of iterations
    eps = 0.01; % Convergence criteria
    
    
%     % Training starts
%     train_images = dir(train_dir);
%     
%     Or = zeros(1);
%     Og = zeros(1);
%     Ob = zeros(1);
%     
%     for i = 1:length(train_images)
%         X = imread([train_images(i).folder '\' train_images(i).name]);
%         X = im2double(X);
%         X = imgaussfilt(X,4);
%         [I] = roipoly(X);
%         [x,y] = find(I);
%         for j = 1:length(x)
%             Or = [Or X(x(j),y(j),1)];
%             Og = [Og X(x(j),y(j),2)];
%             Ob = [Ob X(x(j),y(j),3)];
%         end
%     end
% 
%     twodsize = size(Or,2);
%     Or = Or(1,2:twodsize);
%     Og = Og(1,2:twodsize);
%     Ob = Ob(1,2:twodsize);
%     twodsize = size(Or,2);
%     Y = [Or;Og;Ob];

    twodsize = size(Y,2);

    % Calculating the co-variance matrix of 3-D [R,G,B] data
    sigOrange = ((Y-mean(Y,2))*(Y-mean(Y,2))')/twodsize;
    
    % Initializing parameters
    u = rand(3,K); % K 3x1 vectors
    sig = repmat(sigOrange,1,1,K); % nxnx3 3D array
%     sig = rand(3,3,K);
    pii = rand(1,K); % 1xK vector
    iter = 1;
    while (iter<=max_iterations)
        ui = u;
        for i = 1:K               % For every gaussian model we are finding the optimized parameters.
            weight = zeros(1,twodsize);
            invsig = eye(3,3)\sig(:,:,i);
            % E-Step
            for j = 1:twodsize    % For every pixel in the set of orange pixels obtained from the training set, we are finding out which model fits best and assigning weights accordingly.
                weight_den = 0;
                PCx = computePosterior(Y(:,j),u(:,i),sig(:,:,i),invsig);
                weight_num = pii(i)*PCx;    % pii is the size of each gaussian or can be thought of weight of each gaussian needed for our total model.
                for k = 1:K         % For every gaussian model we are computing how well this pixel fits the model by taking a normalized weight.
                    invsigg = eye(3,3)\sig(:,:,k);
                    weight_den = weight_den + pii(k)*computePosterior(Y(:,j),u(:,k),sig(:,:,k),invsigg);
                end
                weight(j) = weight_num/weight_den;  %   This weight corresponds to the j'th pixel's probability that it belongs to ith Gaussian.               
            end
            
            % M-Step
            
            pii(i) = sum(weight)/twodsize;
            % Pii increases if the cluster covers more points, decreases if
            % it covers less points.
            % This gives the total responsibility/weight assigned to ith cluster for the entire image.
            % This basically depends on the number of good
            % probabilities that come out. i.e if there are many pixels
            % that have a higher probability being in this cluster,
            % then this cluster is given more weight when compared to
            % other clusters.
            
            u(:,i) = (Y*(weight)')/sum(weight);     
            %   Mean is the center of the ellipsoid. Basically,we are
            %   trying to find where to place the center. Where will we
            %   place it? We will place near the highest pixel density i.e.
            %   for pixels for which the probability of those being in this
            %   cluster. 
            sig(:,:,i) = ((((Y-u(:,i)).*weight)*(Y-u(:,i))'))/sum(weight);
            %   Now we have placed the center, but the std
            %   deviation/co-variance might be making the gaussian curve
            %   cover more area that necessary. Hence, we need to reshape
            %   the curve with the new mean and the variation of points
            %   around this mean.!!!
        end
        iter = iter + 1;
        if (norm(sum(u-ui,2))<eps)
            break;
        end
    end
    
%   Calculating the relation between distance and area and getting the
%   coefficients of the polynomial
%   Should do this the first time to get the relation and the polynomial
%   coefficients, so that next time just plug it.
%   Deriving the relation between area(total number of pixels) and distance
%   of the orange ball using polyfit.
%     d = [106 114 121 137 144 152 160 168 176 192 200 208 216 223 231 248 256 264 280 68 76 91 99];
%     p = polyfit(a,d,2);
%     y = polyval(p,a);
%     plot(x,y1,'o')
    poly = [0.0015 -1.2887 336.1951];
    save('GMM_params.mat','sig','u','pii','Y','poly')

end