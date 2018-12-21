import gtsam.*

%% Initialization -> Extract the 10th tag's corner points and  solve for Homography
% 10th tag's position is taken as prior information as it is initialized as the origin.
% 10th tag's location in DetAll cell is 19. Data is in form -> [TagID, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y].
eLe = DetAll{1,1}(19,:);
% Extracting 4 locations in the image frame.
p = eLe(2:9);
x1 = [p(1);p(2);1];
x2 = [p(3);p(4);1];
x3 = [p(5);p(6);1];
x4 = [p(7);p(8);1];
c = [x1 x2 x3 x4];

% World coordinates of the 10th tag. This is the assumption/initialization.
X1 = [0;0;1];
X2 = [TagSize;0;1];
X3 = [TagSize;TagSize;1];
X4 = [0;TagSize;1];
X = [X1 X2 X3 X4];

% Solving for Homography. A*h=0; and obtaining R,T matrices associated with it
[~, r, t] = estimateTransformations(X,c,K);
clear X1 X2 X3 X4 x1 x2 x3 x4 ele p

%% Extract ObservedLandMark's Locations for each frame.
ObservedTags = cell(length(DetAll), 1);
for count = 1:length(DetAll)
    ObservedTags{count}.Idx = DetAll{count}(:,1).';
    ObservedTags{count}.pos1 = DetAll{count}(:,2:3);
    ObservedTags{count}.pos2 = DetAll{count}(:,4:5);
    ObservedTags{count}.pos3 = DetAll{count}(:,6:7);
    ObservedTags{count}.pos4 = DetAll{count}(:,8:9);
end

%% Estimate WorldFrame coordinates
[val,WorldLandMarks,R,T] = convertToWorldCoordinates(K,r,t.',ObservedTags);
% Plot the above R, T to get the initial calculated position of landmarks and camera relative to each other.

%% SLAM using GTSAM! 
% Create Symbols for the graph

% x -> pose of the camera relative to world's origin (p1 of 10th tag).
x = cell(length(DetAll), 1);
for frame = 1:length(DetAll)
    x{frame} = symbol('x', frame);
end

% L -> Landmark's 3-D world coordinates.
Tags = [];
for count = 1:length(ObservedTags)
    Tags = [Tags, ObservedTags{count}.Idx];
end
% Unique landmarks identified by tagID
Tags = unique(Tags);
% Define symbols for each corner of the tag
L = cell(4*length(Tags),1); % Every tag has 4 corner-points
k = 1;
for count = 1:length(Tags)
    for i = 1:4
        L{k} = symbol('L', k+count-1);
        k = k + 1;
    end
end

%% Create graph container and add factors to it
graph = NonlinearFactorGraph;

%% Add priors to camera pose and Landmark coordinates (origin)
% This intial pose is pose of camera in frame1 w.r.t 10th tag's p1 point
priorRotTrans = Pose3(Rot3(R(:,1:3)),Point3(T(:,1)));
% This Noise indicates the co-variance assigned to the prior
poseNoiseSigmas = noiseModel.Diagonal.Sigmas([0.01;0.01;0.01;0.01;0.01;0.01]);
graph.add(PriorFactorPose3(x{1},priorRotTrans,poseNoiseSigmas));

% Adding [0,0,0] prior coordinates to Landmark-1
pointPriorNoise  = noiseModel.Isotropic.Sigma(3,0.000001);
graph.add(PriorFactorPoint3(L{1}, Point3(0,0,0), pointPriorNoise));

%% Add constraints between steps

% 1-Constraint
% In our case, Odometry is the relative camera pose/frames w.r.t each other.
% In this case, we are taking it to be Identity(R) and zero(T). 

% Giving High covariance to this value as it is an assumption that is inaccurate.
relativePoseNoise =  noiseModel.Diagonal.Sigmas([0.6;0.6;0.6;0.8;0.8;0.8]);
relativePose = Pose3(Rot3(eye(3)),Point3(0,0,0));
for frame = 1:length(DetAll)
    if frame < length(DetAll)
        graph.add(BetweenFactorPose3(x{frame}, x{frame+1}, relativePose, relativePoseNoise));
    else
        graph.add(BetweenFactorPose3(x{frame}, x{1}, relativePose, relativePoseNoise));
    end
end

% 2-Constraint
% This is between camera pose and the landmark coordinates -> Homography!!

% This would be given covariane on a lowerside as we are not entirely sure
% about the measurement noise of the camera.
transformationNoise = noiseModel.Diagonal.Sigmas([0.1;0.1]);
Calibration = Cal3_S2(K(1,1), K(2,2), 0, K(1,3), K(2,3));
for frame = 1:length(DetAll)
    for i = 1:length(ObservedTags{frame}.Idx)
        TagIdx = find(Tags == ObservedTags{frame}.Idx(i));
        LandMarkIdx = TagIdx*4;
        graph.add(GenericProjectionFactorCal3_S2(Point2(DetAll{frame}(i,8:9)'),transformationNoise, x{frame}, L{LandMarkIdx},Calibration));
        graph.add(GenericProjectionFactorCal3_S2(Point2(DetAll{frame}(i,6:7)'),transformationNoise, x{frame}, L{LandMarkIdx-1},Calibration));
        graph.add(GenericProjectionFactorCal3_S2(Point2(DetAll{frame}(i,4:5)'),transformationNoise, x{frame}, L{LandMarkIdx-2},Calibration));
        graph.add(GenericProjectionFactorCal3_S2(Point2(DetAll{frame}(i,2:3)'),transformationNoise, x{frame}, L{LandMarkIdx-3},Calibration));
    end
end

% 3-Constraint
% This is the constraint on landmark positions in world. Distance between them is known.
relativeLocNoise  = noiseModel.Isotropic.Sigma(3,0.000001);
relativeLoc12 = Point3(TagSize,0,0);
relativeLoc23 = Point3(0,TagSize,0);
relativeLoc34 = Point3(-TagSize,0,0);
relativeLoc41 = Point3(0,-TagSize,0);
relativeLoc13 = Point3(TagSize,TagSize,0);
relativeLoc24 = Point3(-TagSize,TagSize,0);
for count = 1:length(Tags)
    LandMarkIdx = count*4;
    graph.add(BetweenFactorPoint3(L{LandMarkIdx-0}, L{LandMarkIdx-1}, relativeLoc34, relativeLocNoise));
    graph.add(BetweenFactorPoint3(L{LandMarkIdx-1}, L{LandMarkIdx-2}, relativeLoc23, relativeLocNoise));
    graph.add(BetweenFactorPoint3(L{LandMarkIdx-2}, L{LandMarkIdx-3}, relativeLoc12, relativeLocNoise));
    graph.add(BetweenFactorPoint3(L{LandMarkIdx-3}, L{LandMarkIdx-0}, relativeLoc41, relativeLocNoise));
    graph.add(BetweenFactorPoint3(L{LandMarkIdx-1}, L{LandMarkIdx-3}, relativeLoc13, relativeLocNoise));
    graph.add(BetweenFactorPoint3(L{LandMarkIdx-0}, L{LandMarkIdx-2}, relativeLoc24, relativeLocNoise));
end

% print
% graph.print(sprintf('\nFull grObservedLandMarks{frame}.Idxaph:\n'));

%% Initialize values
initialEstimate = Values;
for frame = 1:length(DetAll)
    initialEstimate.insert(x{frame}, Pose3(Rot3(R(:,frame*3-2:frame*3)),Point3(T(:,frame))));
    for count = 1:length(ObservedTags{frame}.Idx)
        TagIdx = find(Tags == ObservedTags{frame}.Idx(count));
        LandMarkIdx = TagIdx*4;
        try
            initialEstimate.insert(L{LandMarkIdx-0}, Point3([WorldLandMarks{frame}.pos4(count,:),0]'));
            initialEstimate.insert(L{LandMarkIdx-1}, Point3([WorldLandMarks{frame}.pos3(count,:),0]'));
            initialEstimate.insert(L{LandMarkIdx-2}, Point3([WorldLandMarks{frame}.pos2(count,:),0]'));
            initialEstimate.insert(L{LandMarkIdx-3}, Point3([WorldLandMarks{frame}.pos1(count,:),0]'));
        catch
            continue;
        end
    end
end

initialEstimate.print(sprintf('\nInitial estimate:\n'));


%% Fine grain optimization, allowing user to iterate step by step
parameters = LevenbergMarquardtParams;
parameters.setlambdaInitial(0.1 );
parameters.setVerbosityLM('trylambda');
optimizer = LevenbergMarquardtOptimizer(graph, initialEstimate, parameters);

for i=1:10
    optimizer.iterate();
end
result = optimizer.values();
result.print(sprintf('\nFinal result:\n  '));

%% Optimize using Dogleg optimization
% params = DoglegParams;
% params.setAbsoluteErrorTol(1e-15);
% params.setRelativeErrorTol(1e-15);
% params.setVerbosity('ERROR');
% params.setVerbosityDL('VERBOSE');
% params.setOrdering(graph.orderingCOLAMD());
% optimizer = DoglegOptimizer(graph, initialEstimate, params);
% 
% result = optimizer.optimizeSafely();
% result.print('final result');

%% Normal plot
figure;title('DatasetwithGTSAM');
hold on;
for frame = 1:length(DetAll)
    scatter3(result.at(x{frame}).translation.x,result.at(x{frame}).translation.y,result.at(x{frame}).translation.z,'.');
end

for count = 1:length(Tags)*4
    plot(result.at(L{count}).x,result.at(L{count}).y,'g*');
end
hold off
