function [ vConstraints ] = generateconstraints(PTAM, World, nConstraints)

nPoints = size(PTAM.Map.points,2);
usedPoints = [];



for i = 1:nConstraints
    [id1 usedPoints] = getpointid(nPoints, usedPoints);
    [id2 usedPoints] = getpointid(nPoints, usedPoints);
    
    
    if id2 < id1
        temp = id1;
        id1 = id2;
        id2 = temp;
    end
    
    gtid1 = PTAM.Map.points(id1).gtid;
    gtid2 = PTAM.Map.points(id2).gtid;
    
    value = norm(World.Map.points(gtid1).location - World.Map.points(gtid2).location);
    
    vConstraints{i}.p1 = id1;
    vConstraints{i}.p2 = id2;
    vConstraints{i}.value = value; 
    
end












end


function [id usedPoints] = getpointid(nPoints, usedPoints)
id = randi([1 nPoints]);

while sum(usedPoints == id) > 0
    id = randi([1 nPoints]);
end

usedPoints = [usedPoints id];
end




