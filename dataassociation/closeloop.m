function [PTAM] = closeloop(PTAM, World)


%Correct keyframe measurement ids
for i = size(PTAM.KeyFrames,2)
    for j = 1:size(PTAM.KeyFrames(i).ImagePoints,2)
        gtid = PTAM.KeyFrames(i).ImagePoints(j).gtid;
        newid = World.Map.points(gtid).estids(1);
        if newid <= size(World.Map.points,2)
            PTAM.KeyFrames(i).ImagePoints(j).id = newid;
        else
            display('problem');
        end
    end
end

gtpointcount = size(World.Map.points,2);

PTAM.Map.points = PTAM.Map.points(1:gtpointcount);
PTAM.mapcount = gtpointcount;
    

end

