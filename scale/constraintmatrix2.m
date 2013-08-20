function [ C ] = constraintmatrix2(World, count)

ngtpoints = size(World.Map.points,2);

C = zeros(ngtpoints,ngtpoints);

gtids = 1:200;
gtids = gtids';

for i = 1:199
    for j = i+1:200
    
    
    
    if mod(i,10) == 0
        clc;
        display(i);
    end
        
   
%    
%     
%     [consi, consj] = generateframeids(gtids);
%     
% %     while C(consi,consj) > 0 
% %         [consi, consj] = generateframeids(gtids);
% %     end
    
    consi = i;
    consj = j;
    

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

