function [ error points errors] = calculateworlderror(GTMap, EstMap)


error = 0;
points = 0;

errors = zeros(size(GTMap.points,2),1);

for i = 1:size(GTMap.points,2)
    for j = 1:size(EstMap.points,2)
        if (GTMap.points(i).id == EstMap.points(j).gtid)
            
            errors(i) = norm(GTMap.points(i).location-EstMap.points(j).location);
            points = points + 1;
            break;
        end
    end
end


error = sum(errors);



end

