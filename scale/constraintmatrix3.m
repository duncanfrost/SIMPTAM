function [ C ] = constraintmatrix3(World,counts)

ngtpoints = size(World.Map.points,2);

C = zeros(ngtpoints,ngtpoints);
Frames = World.KeyFrames;

gtids = [];
for i = 1:size(Frames,2)
    npoints = size(Frames(i).ImagePoints,2);
    oldgtids = gtids;
    gtids = zeros(npoints,1);
    
    for j = 1:size(Frames(i).ImagePoints,2)
        gtids(j) = Frames(i).ImagePoints(j).gtid;
    end
     
%     gtids = setdiff(gtids,oldgtids);
    
    for j = 1:counts(i)
    
    [consi, consj] = generateframeids(gtids);
    
    while C(consi,consj) > 0 
        [consi, consj] = generateframeids(gtids);
    end
    
    
    X1 = World.Map.points(consi).location;
    X2 = World.Map.points(consj).location;
    C(consi,consj) = norm(X1 - X2);
    
    
    
  
    end
    
   
end


clc;
display(sum(sum(C>0)));
display('Finished');


end


function [consi, consj] = generateframeids(gtids)
npoints = size(gtids,1);
indexi = randi([1 npoints-1]);
indexj = randi([indexi+1 npoints]);
    
consi = gtids(indexi);
consj = gtids(indexj);
end

