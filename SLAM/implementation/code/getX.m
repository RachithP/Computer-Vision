function temp = getX(observedlandmarks,h)
    
% Apply Homography 'h' inverse to all landmarks in 'observedlandmarks'.
% Return World coordinates of all landmarks.

    % Calculate world coordinates using hinv
    temp.pos1 = inv(h)*[observedlandmarks.pos1(:,1) observedlandmarks.pos1(:,2) ones(length(observedlandmarks.Idx),1)].';
    temp.pos2 = inv(h)*[observedlandmarks.pos2(:,1) observedlandmarks.pos2(:,2) ones(length(observedlandmarks.Idx),1)].';
    temp.pos3 = inv(h)*[observedlandmarks.pos3(:,1) observedlandmarks.pos3(:,2) ones(length(observedlandmarks.Idx),1)].';
    temp.pos4 = inv(h)*[observedlandmarks.pos4(:,1) observedlandmarks.pos4(:,2) ones(length(observedlandmarks.Idx),1)].'; 
    for i = 1:length(observedlandmarks.Idx)
        temp.pos1(:,i) = temp.pos1(:,i)/temp.pos1(3,i);
        temp.pos2(:,i) = temp.pos2(:,i)/temp.pos2(3,i);
        temp.pos3(:,i) = temp.pos3(:,i)/temp.pos3(3,i);
        temp.pos4(:,i) = temp.pos4(:,i)/temp.pos4(3,i);
    end
end