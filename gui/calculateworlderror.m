function [ error points ] = calculateworlderror(Map1, Map2)
%CALCULATEWORLDERROR Summary of this function goes here
%   Detailed explanation goes here

error = 0;
points = 0;

for i = 1:size(Map1.points,2)
    
    for j = 1:size(Map2.points,2)
        if (Map1.points(i).id == Map2.points(j).id)
            error = error + norm(Map1.points(i).location-Map2.points(j).location);
            points = points + 1;
        end
    end
end


end

