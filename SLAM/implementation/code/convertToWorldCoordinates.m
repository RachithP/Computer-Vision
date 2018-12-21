function [val,landmarks,R,T] = convertToWorldCoordinates(K,r,t,observedlandmarks)

landmarks = cell(length(observedlandmarks), 1);
cameraParams = cameraParameters('IntrinsicMatrix',K.','RadialDistortion',[0 0]); 
T = [];
R = [];
value = [];
position1x = [];
position2x = [];
position3x = [];
position4x = [];
position1y = [];
position2y = [];
position3y = [];
position4y = [];

for count = 1:length(observedlandmarks) 
    
    landmarks{count}.Idx = observedlandmarks{count}.Idx;
    k = 1;
    
    if count > 1
        
        for i = 1:length(observedlandmarks{count-1}.Idx)
            if ~ismember(observedlandmarks{count-1}.Idx(i),value)
                value = [value observedlandmarks{count-1}.Idx(i)];
                position1x = [position1x landmarks{count-1}.pos1(i,1)];
                position1y = [position1y landmarks{count-1}.pos1(i,2)];
                position2x = [position2x landmarks{count-1}.pos2(i,1)];
                position2y = [position2y landmarks{count-1}.pos1(i,2)];
                position3x = [position3x landmarks{count-1}.pos3(i,1)];
                position3y = [position3y landmarks{count-1}.pos1(i,2)];
                position4x = [position4x landmarks{count-1}.pos4(i,1)];
                position4y = [position4y landmarks{count-1}.pos1(i,2)];
            end
        end
%         [a,b] = ismember(observedlandmarks{count}.Idx, value);
%         POS = b(find(b));
%         pos = find(a);

        [a,~] = ismember(observedlandmarks{count}.Idx, observedlandmarks{k}.Idx);
        while ~(length(find(a==1))>4)
            k = k + 1;
            [a,~] = ismember(observedlandmarks{count}.Idx, observedlandmarks{k}.Idx);
        end                
        [a,b] = ismember(observedlandmarks{count}.Idx, observedlandmarks{k}.Idx);
        POS = b(find(b));
        pos = find(a);
        
        % Get image coordinates of points in the curr image frame.
        x = [observedlandmarks{count}.pos1(pos,:);...
             observedlandmarks{count}.pos2(pos,:);...
             observedlandmarks{count}.pos3(pos,:);...
             observedlandmarks{count}.pos4(pos,:)];

        % Get their corresponding world coordinates calculated from 1st frame.
        X = [[landmarks{k}.pos1(POS,:) zeros(length(POS),1)];...
             [landmarks{k}.pos2(POS,:) zeros(length(POS),1)];...
             [landmarks{k}.pos3(POS,:) zeros(length(POS),1)];...
             [landmarks{k}.pos4(POS,:) zeros(length(POS),1)]];
%         X = [[position1x(POS)'  position1y(POS)' zeros(length(POS),1)];...
%              [position2x(POS)'  position2y(POS)' zeros(length(POS),1)];...
%              [position3x(POS)'  position3y(POS)' zeros(length(POS),1)];...
%              [position4x(POS)'  position4y(POS)' zeros(length(POS),1)]];

        [r,t] = estimateWorldCameraPose(x,X,cameraParams);
        
    end
    
    % Store R,T values to feed it into graph later on.
    T = [T t.'];
    R = [R r];
    
    % Get the new h matrix for new frame
    h = K*[r(:,1:2) t.'];
    
    % Get world coordinates using this h matrix
    temp = getX(observedlandmarks{count},h);
    landmarks{count}.pos1 = temp.pos1(1:2,:)';
    landmarks{count}.pos2 = temp.pos2(1:2,:)';
    landmarks{count}.pos3 = temp.pos3(1:2,:)';
    landmarks{count}.pos4 = temp.pos4(1:2,:)';
        
end
val = [value;position1x;position1y;position2x;position2y;position3x;position3y;position4x;position4y];
end