function [ Map ] = appendmap(Map, points)
for i = 1:size(points,2)
    haspoint = false;
    for j = 1:size(Map.points,2)
        if points(i).id == Map.points(j).id
            haspoint = true;
        end
    end
    if haspoint == false
        Map.points(size(Map.points,2)+1) = points(i);
    end
    
    
end
end

