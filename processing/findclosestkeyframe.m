function [ ClosestKeyFrames indices ] = findclosestkeyframe(KeyFrames, position, range)
%FINDCLOSESTKEYFRAME Finds the closest keyframe to a specified point 

distances = zeros(size(KeyFrames,2),1);
indices = 1:size(KeyFrames,2);
for i = 1:size(KeyFrames,2)
    kfposition = camcentre(KeyFrames(i).Camera.E);
    dist = norm(kfposition-position);
    distances(i) = dist;
end
    

SortedKeyFrames = KeyFrames;



for i = 1:size(KeyFrames,2)-1
    minkfcount = i;
    for j = i+1:size(KeyFrames,2)
        if distances(j) < distances(minkfcount)
            minkfcount = j;
        end
    end
    
    
    if minkfcount ~= i
       TempKF = SortedKeyFrames(i);
       SortedKeyFrames(i) = SortedKeyFrames(minkfcount);
       SortedKeyFrames(minkfcount) = TempKF;
       
       tempindex = indices(i);
       indices(i) = indices(minkfcount);
       indices(minkfcount) = tempindex;
       
       tempdistance = distances(i);
       distances(i) = distances(minkfcount);
       distances(minkfcount) = tempdistance;
    end
end

    




ClosestKeyFrames = SortedKeyFrames(1:range);
indices = indices(1:range);




end

