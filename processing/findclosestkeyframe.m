function [ ClosestKeyFrame minkfcount ] = findclosestkeyframe(KeyFrames, position)
%FINDCLOSESTKEYFRAME Finds the closest keyframe to a specified point 







mindist = 1000;
minkfcount = 0;


for i = 1:size(KeyFrames,2)-1
    
    kfposition = camcentre(KeyFrames(i).Camera.E);
    
    dist = norm(kfposition-position);
    if dist < mindist
        mindist = dist;
        minkfcount = i;
    end
end


display('Cloest keyframe:');
display(minkfcount);
if minkfcount > 0
    ClosestKeyFrame = KeyFrames(minkfcount);
else
    ClosestKeyFrame = [];
end

end

