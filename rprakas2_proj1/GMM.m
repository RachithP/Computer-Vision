% % Gaussian Mixture Model
tic

% T = 0.000874715; % single GM
T = 0.00091099;
K = 5; % Number of Gaussians

action = input('What do you want to run now?\n==>test/train?\n==>', 's');

if strcmp(action,'train')
    [u,sig,pii,Y,poly] = train_GMM('train_images\*.jpg',K,Y);
elseif strcmp(action,'test')
    model = 'GMM_params.mat';
%     load(model,'u','sig','pii','Y');
    if ( exist('u') && exist('sig') && exist('model') )
%         out = test_GMM('test_images\*.jpg',T,u,sig,pii);
    else
        disp('Please train the model first.')
    end
else
    disp('Input either test/train.')
end

% Plot ellipsoids
plotGMM(u,sig)
scatter3(Y(1,:),Y(2,:),Y(3,:),3,'r')
xlabel('R component')
ylabel('G component')
zlabel('B component')
% hold on
% plotGMM(u,sig)
hold off

% morphological tuning and measureDepth;
% if ~strcmp(action,'train')
%     outputImages = dir('test_images\output_*.jpg');
%     for i = 1:length(outputImages)
%         computeDistance([outputImages(i).folder '\' outputImages(i).name],poly);
%     end
% end

toc