function [PTAM World] = closeloop(PTAM, World)


for i = 1:size(World.Map.points,2)
    id = World.Map.points(i).estids(1);
    newMap.points(i).id = i;
    newMap.points(i).location = PTAM.Map.points(id).location;
    newMap.points(i).gtid = i;
    World.Map.points(i).estids = i;
    
    for j = 1:size(PTAM.KeyFrames,2)
        for k = 1:size(PTAM.KeyFrames(j).ImagePoints,2)
            gtid = PTAM.KeyFrames(j).ImagePoints(k).gtid;
            if gtid == i
                PTAM.KeyFrames(j).ImagePoints(k).id = i;
            end
        end
    end     
end

PTAM.Map = newMap;

gtpointcount = size(PTAM.Map.points,2);

PTAM.Map.points = PTAM.Map.points(1:gtpointcount);
PTAM.mapcount = gtpointcount;




end

