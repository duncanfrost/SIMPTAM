function [ error points ] = calculateworlderror(GTMap, EstMap)


error = 0;
points = 0;

for i = 1:size(GTMap.points,2)
    for j = 1:size(EstMap.points,2)
        if (GTMap.points(i).id == EstMap.points(j).gtid)
            error = error + norm(GTMap.points(i).location-EstMap.points(j).location);
            points = points + 1;
            break;
        end
    end
end


end

